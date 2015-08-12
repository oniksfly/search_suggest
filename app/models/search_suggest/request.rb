module SearchSuggest
  class Request
    ALPHABET = %w(а в г д е ё ж з и й к л м н о п р с т у ф х ц ч ш щ ъ ы ь э ю я)
    ALPHABET_EN = %w(a b c d e f g h i j k l m n o p q r s t u w x y z)
    NUMBERS = %w(0 1 2 3 4 5 6 7 8 9)
    SIGNS = ALPHABET + ALPHABET_EN + NUMBERS
    STOP_WORDS = %w(на под для в из к во по с)

    def self.prepare_request(params)
      response = {
        max_results: (params[:max_results].present? and SearchSuggest::RESULTS_COUNT.include?(params[:max_results].to_i)) ? params[:max_results].to_i : SearchSuggest::RESULTS_COUNT.first,
        allow: false, # разрешение на приём-передачу подсказок из ПС
        query: '',
        messages: {},
        suggestions: [],
        iteration: 0,
        count: 0
      }

      if request_query_valid? params[:request]
        response[:query] = response[:alter_query] = params[:request].mb_chars.downcase.to_s
        response[:allow] = true
      else
        response[:messages] = self.add_message!(response[:messages], :danger, "Неопределённость невыносима: хотя бы #{SearchSuggest::MIN_REQUEST_LENGTH} знака в запросе.")
      end

      response
    end

    def self.check_input_request(input_request)
      response = {
          messages: {},
          allow: false,
      }

      if input_request.is_a?(Hash)
        if request_query_valid? input_request[:query]
          if input_request[:max_results].present? and SearchSuggest::RESULTS_COUNT.include?(input_request[:max_results].to_i)
            if input_request[:count] < input_request[:max_results]
              response[:max_results] = input_request[:max_results]
              response[:query] = input_request[:query]
              response[:iteration] = input_request[:iteration]
              response[:count] = input_request[:count]
              response[:allow] = input_request[:allow]
              response[:suggestions] = input_request[:suggestions]
            else
              response[:messages] = self.add_message!(response[:messages], :info, 'Запрошенное количество подсказок уже получено, подумайте о поисковой системе.')
            end
          else
            response[:messages] = self.add_message!(response[:messages], :danger, 'Техническая проблема на стороне сервиса: получено некорректное значение для максимального количества подсказок.')
          end
        else
          response[:messages] = self.add_message!(response[:messages], :danger, "Неопределённость невыносима: хотя бы #{SearchSuggest::MIN_REQUEST_LENGTH} знака в запросе.")
        end
      else
        response[:messages] = self.add_message!(response[:messages], :danger, 'Техническая проблема на стороне сервиса: перед попыткой получить подсказки не был получен правильный запрос.')
      end
      response
    end

    def self.process_request(input_request, words, exist_requests)
      response = self.check_input_request(input_request)
      response[:words] = words if response[:iteration]
      add_new_words = true
      if response[:allow]
        yandex_data = if response[:iteration] == 0
                        self.get_suggests_yandex(response[:query], exist_requests)
                      else
                        sign = SIGNS[response[:iteration] - 1]
                        if sign.present?
                          # Поиск по алфавиту
                          self.get_suggests_yandex(response[:query] + " #{sign}", exist_requests)
                        elsif response[:words].present?
                          # Поиск по потенциальным словам
                          add_new_words = false
                          yd = self.get_suggests_yandex(response[:query] + " #{response[:words].first}", exist_requests)
                          response[:words].shift
                          yd
                        else
                          # Завершаем поиск
                          response[:allow] = false
                          response[:messages] = self.add_message!(response[:messages], :info, "Подсказок больше нет, нашёл #{ response[:count] }.")
                        end
                      end
        response[:iteration] += 1

        if yandex_data[:suggestions].present?
          yandex_data[:words] = self.add_perspective_words(response[:query], yandex_data[:suggestions], response[:words]) if add_new_words
          response[:suggestions].concat yandex_data[:suggestions]
          response[:count] += response[:suggestions].length
        end
      end
      response
    end

    def self.get_suggests_yandex(query, exist_queries)
      data = {
          suggestions: [],
          query: query
      }

      uri = URI::HTTP.build(host: 'suggest.yandex.ru', path: '/suggest-ya.cgi', query: { part: query }.to_query)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      response = http.request(request)
      if response.present? and response.body.present?
        match = response.body.match(/suggest.apply\((.+)\)/)
        if match[1].present?
          result = JSON.parse "[#{match[1]}]"
          if result[0].present?
            data[:query] =  result[0][0] if result[0][0].present?
            result[0][1].each { |new_query| data[:suggestions] << new_query unless exist_queries.include?(new_query) } if result[0][1].present?
          end
        end
      end
      data
    end

    def self.add_perspective_words(query, strings_list, words)
      # TODO: ввести лимит на количество сохраняемых слов
      query_by_words = query.split(' ')
      strings_list.each do |string|
        string_by_words = string.split(' ')
        if string_by_words.present?
          left_words = string_by_words - query_by_words - STOP_WORDS
          left_words.each { |word| words << word unless words.include?(word) } if left_words.present?
        end
      end
      words
    end

    def self.set_controller_store!(cs, data)
      if data[:iteration] == 1
        cs[:suggests] = []
        cs[:words] = []
      end
      cs[:suggests].concat data[:suggestions] if data[:suggestions].present?
      cs[:words] = data[:words] if data[:words].present?
      cs
    end

    private
      def self.request_query_valid?(query)
        query.present? and query.length >= SearchSuggest::MIN_REQUEST_LENGTH
      end

      # Рекомендуемые статусы будут работать с бутстрапом: danger, notice
      def self.add_message!(messages, status, message)
        if messages.is_a?(Hash)
          messages[status.to_sym] = [] unless messages[status.to_sym].present?
          messages[status.to_sym] << message
        end
        messages
      end
  end
end
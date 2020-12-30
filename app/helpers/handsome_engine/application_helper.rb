module HandsomeEngine
  module ApplicationHelper
    # 转成两位小数的字符串
    def format_money(value = nil)
      format('%.2f', value.to_f)
    end

    # 标准渲染
    def render_json_standard(json, obj)
      case obj.class.superclass.name
      when 'ActiveRecord::Relation', 'ActiveRecord::AssociationRelation', 'ActiveRecord::Associations::CollectionProxy'
        json.array! obj do |o|
          json.partial! "standard/#{o.class.name.underscore}", obj: o
        end
      when 'ApplicationRecord'
        json.partial! "standard/#{obj.class.name.underscore}", obj: obj
      else
        {}
      end
    end

    # 智能渲染
    def render_json_intelligence(json, obj, accepts = [], excepts = [], extras=[], partials=[])
      case obj.class.superclass.name
      when 'ActiveRecord::Relation'
        json.array! obj do |o|
          render_json_custom(json, o, accepts, excepts, extras)
        end
      when 'ActiveRecord::AssociationRelation'
        json.array! obj do |o|
          render_json_custom(json, o, accepts, excepts, extras)
        end
      when 'ActiveRecord::Associations::CollectionProxy'
        obj.each do |o|
          render_json_custom(json, o, accepts, excepts, extras)
        end
      when 'ApplicationRecord'
        return {} if obj.blank?
  
        render_json_custom(json, obj, accepts, excepts, extras, partials)
      else
        {}
      end
    end
  
    def render_json_custom(json, obj, accepts, excepts, extras=[], partials=[])
      accepts = obj.class.columns.map(&:name).map(&:to_sym) if accepts.blank?
      accepts -= excepts if excepts.present?
  
      accepts.each do |column|
        value = obj.__send__(column)
  
        value =
          if value.is_a? String
            case obj.class.column_for_attribute(column).type
            when :decimal
              value.to_f
            else
              value
            end
          elsif value.is_a? Array
            value
          elsif value.is_a? Float
            value.round(2)
          elsif value.is_a? ActiveSupport::TimeWithZone
            value.strftime('%F %T')
          else
            value
          end
  
        json.__send__(column, value)
      end
  
      extras.each do |extra|
        json.__send__(extra, obj.__send__(extra))
      end if extras.present?
  
      partials.each do |partial|
        @result = obj.__send__(partial[:result])
  
        next if @result.blank?
        
        @extras = partial[:extras]
        @accepts = partial[:accepts]
        @excepts = partial[:excepts]
        @partials = partial[:partials]
        
        json.__send__(partial[:result], @result, partial: 'intelligence', as: partial[:result])
  
      end if partials.present?
    end
  
    #
    # 渲染json返回属性
    #
    # @param json [Unknown] json对象
    # @param obj [ActiveRecord] 数据库表的对象
    # @param attrs [Array] 需要渲染的表属性符号数组
    #
    def render_json_attrs(json, obj, attrs = nil)
      # Rails.logger.info "obj=>#{obj}"
      return if obj.blank?
  
      attrs = obj.class.columns.map(&:name) if attrs.blank?
      attrs.each do |column|
        next unless column != 'deleted_at'
  
        key = column.to_sym
        column_type = obj.class.columns.select { |c| c.name == column.to_s }.first.type
        value = obj.__send__(column.to_sym)
        if value.present? || value.is_a?(Array)
          value = value.to_time&.strftime('%F') if key.to_s == 'date' || key.to_s.include?('_date')
          # 兼容代码
          # value = value.to_time&.strftime('%F %H:%M') if key.to_s =~ /_at$/
          value = value.to_time&.strftime('%F %H:%M') if obj.class.column_for_attribute(key).type == :datetime
          # value = format('%.2f', value) if value.is_a?(BigDecimal) && (key.to_s.include?('amount') || key.to_s.include?('price'))
          value = value.to_f if obj.class.column_for_attribute(key).type == :decimal
  
          # if (/^([a-zA-Z]+_)*id$/ =~ key).present? || key.to_s == 'whodunnit'
          #   if value.class == Array
          #     value = value.map { |v| v }
          #   else
          #     value = value
          #   end
          # end
        else
          value = ''
          value = value.to_f if obj.class.column_for_attribute(key).type == :decimal
          value = false if value != true && column_type == :boolean
        end
        json.__send__(key, value)
      end
    end
  
    def render_json_attrs_except(json, object, attrs = nil)
      attrs = object.class.columns.map(&:name) - attrs.map(&:to_s) if attrs.present?
  
      render_json_attrs(json, object, attrs)
    end
  
    def render_json_array_partial(obj, array, particle, as)
      obj.__send__('array!', array, partial: particle, as: as)
    end
  
    #
    # 将准确时间转换成相对于当前的时间
    #
    def timeago(time)
      return '' if time.blank?
  
      if time.is_a?(String)
        time = begin
          Time.zone.parse(time)
               rescue StandardError
                 ''
        end
      elsif time.is_a?(Time)
        time = time
      end
  
      return '' if time.blank?
  
      time_now = Time.zone.now
  
      interval = (time_now - time).to_i
  
      case interval
      when 0..3600
        minutes = interval / 60
  
        time = I18n.t('timeago.minutes', minutes: minutes)
  
      when 3601..86_400
        hours = interval / 3600
  
        time = I18n.t('timeago.hours', hours: hours)
  
      when 86_401..2_592_000
        days = interval / 86_400
  
        time = I18n.t('timeago.days', days: days)
  
      else
        time = time.strftime('%F %H:%M')
      end
  
      time
    end
  
    def get_model(model_name)
      ActiveSupport::Dependencies.constantize(model_name.classify)
    end
  
    def render_nested_children(json, obj, &block)
      if obj.children.present?
        json.children obj.children do |child|
          block.call(child)
          render_nested_children(json, child, &block)
        end
  
      end
    end
  
    def humanize(interval)
      return '' if interval.blank?
  
      # interval可能是integer或者24:00:00形式
      secs = if interval.include?(':')
               intervals = interval.split(':').map(&:to_i)
               intervals[0] * 3600 + intervals[1] * 60 + intervals[2]
             else
               interval.to_i
             end
  
      result = [[60, 's'], [60, 'minute'], [24, 'h'], [7, 'd'], [Float::INFINITY, 'w']].map do |count, name|
        next unless secs > 0
  
        secs, n = secs.divmod(count)
  
        "#{n.to_i}#{name}" unless n.to_i == 0
      end.compact.reverse.first
  
      result
    end
  end
end

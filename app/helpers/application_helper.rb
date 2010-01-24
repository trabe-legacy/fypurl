# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
end


#
# Extensiones a los helpers de ActiveRecord
# (ActionView::Helpers::ActiveRecordHelper)
#
module ActionView::Helpers::ActiveRecordHelper
  #
  # Genera el HTML para mostrar los errores que se han producido al intentar
  # crear una nueva instancia de uno o varios objetos.
  #
  # Los mensajes de error son responsabilidad de los validadores del objeto
  # ActiveRecord::Base validado
  #
  # La clase y el id del +div+ pueden modificarse pasando los parametros
  # adicionales +id+ y +class+. Por defecto se usa +form_errors+ en ambos
  # casos.
  #
  # Ej. uso
  #
  #   <%= error_messages_for 'user','account', :id => 'mis_errores'
  #
  def error_messages_for(*params)
    # Extraemos las opciones de los parametros (Siempre es un hash que va al
    # final
    options = params.last.is_a?(Hash) ? params.pop.symbolize_keys : {}

    # Buscamos los objetos de la request que se corresponden a los indicados
    # en los parametros
    objects = params.collect do |object_name|
      instance_variable_get("@#{object_name}")
    end.compact

    # Computamos el total de errores
    count   = objects.inject(0) {|sum, object| sum + object.errors.count }

    # Si hay errores procesamos
    unless count.zero?
      # preparamos los parametros para crear el div externo, buscamos id o clase
      # en la request, si no existen usamos el valor por defecto form_errors
      html = {}
      [:id, :class].each do |key|
        if options.include?(key)
          value = options[key]
          html[key] = value unless value.blank?
        else
          html[key] = 'form_errors'
        end
      end

      # Recuperamos todo slos mensajes de error y montamos el markup
      error_messages = ''
      objects.each do |o|
          o.errors.each { |attr, msg| error_messages += "<li>#{msg}</li>" }
      end

      # Creamos el markup final
      content_tag(:div,
          content_tag(:p, '<strong>Something is wrong with the data provided</strong>. ' +
                          'Please, fix the following errors:' ) +
          content_tag(:ul, error_messages),
              :id => 'errors', :class => 'errors')
    else
      # no hay errores, no devolvemos markup
      ''
    end
  end
end
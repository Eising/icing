class Icing < Sinatra::Base

    # Builds an html input tag
    #
    # == Parameters:
    # type::
    #   the html input type, e.g. text, hidden, password, etc.
    # name::
    #   the form element name
    # value::
    #   (Optional) the value in the input field
    # == Returns:
    # An <input /> tag
    def input(type, name, value=nil)
        if value
            "<input type=\"#{type}\" name=\"#{name}\" value=\"#{value}\" id=\"#{name}\" class=\"form-control\" />"
        else
            "<input type=\"#{type}\" name=\"#{name}\" id=\"#{name}\" class=\"form-control\" />"
        end
    end
end

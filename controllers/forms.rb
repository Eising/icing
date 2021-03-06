class Icing < Sinatra::Base
  namespace '/forms' do
    # @!group Forms controller

    # @method get_forms
    # Get all forms
    get '/' do
      authenticate!
      @pagename = "forms"
      @pagetitle = "Manage forms"

      @forms = Forms.exclude(:deleted => true).all

      erb :'forms/forms'
    end

    # @method get_forms_view
    # View forms
    get '/view/:id' do
      authenticate!
      @pagename = "forms_view"
      @pagetitle = "View forms"

      @form = Forms.where(:id => params[:id])
      if not @form.count == 1
        halt 404
      else
        @form = @form.first
      end

      erb :'forms/view'


    end


    # @method get_forms_compose
    # Compose form
    get '/compose' do
      authenticate!
      @templates = Templates.exclude(:deleted => true).all

      @pagename = "forms_compose"
      @pagetitle = "Manage forms"

      erb :'forms/compose'
    end

    # @macro [attach] sinatra.post
    #   @overload post "$1"
    # @method post_forms_config
    # Configure composed form
    post '/config' do
      authenticate!
      @defaults = {}
      @pagename = "forms_config"
      @pagetitle = "Configure form"

      template_ids = params[:templates]

      tags = []
      template_ids.each do |id|
        get_configurable_tags(id).each { |tag| tags << tag }
      end
      @tags = tags.uniq

      @template_ids = template_ids.join(",")
      @name = params[:name]
      @description = params[:description]

      erb :'/forms/config'
    end


    # @method get_forms_update
    # Update an existing form
    get '/update/:id' do
      authenticate!
      id = params[:id]
      if not Forms.where(:id => id).count == 1
        halt 404
      end
      form = Forms.where(:id => id).first

      template_ids = form.template.collect { |x| x.id }

      tags = []
      template_ids.each do |tid|
        get_configurable_tags(tid).each { |tag| tags << tag }
      end
      @tags = tags.uniq

      @template_ids = template_ids.join(",")

      @name = form.name

      @description = form.description

      @update = true
      @form_id = id
      @defaults = form.defaults

      erb :'/forms/config'
    end


    # @method post_forms_add
    # Submits a form
    post '/add' do
      authenticate!
      defaults = {}
      params.each do |param, value|
        if res = param.match(/^default\.(.*)$/)
          defaults[res[1]] = {} unless defaults.has_key? res[1]
          defaults[res[1]][:value] = value
        end
        if res = param.match(/^name\.(.*)$/)
          defaults[res[1]] = {} unless defaults.has_key? res[1]
          defaults[res[1]][:name] = value
        end
      end
      args = {
        :name => params[:name],
        :description => params[:description],
        :defaults => defaults.to_json,
        :require_update => nil,
        :user_id => current_user.id
      }
      if params[:form_id]
        form = Forms.where(:id => params[:form_id])
        if form.count == 1
          form = form.first
          form.update(args)
        #          flash[:notice] = "updated form ##{form.id}"
        else
          halt 404
        end
      else
        form = Forms.create(args)
        template_ids = params[:template_ids].split(",")
        template_ids.each { |id| form.add_template(id) }

        #        flash[:notice] = "Added form ##{form.id}"
      end
      redirect to('/forms/')
    end

    # @method get_forms_delete
    # Deletes a form
    # @param id [Integer] The form id to delete
    get '/delete/:id' do
      authenticate!

      # logic to delete id
      form = Forms.where(:id => params[:id])
      if form.count == 1
        form.update(:deleted => true)
        #            flash[:notice] = "Deleted form ##{params[:id]}"
        redirect to('/forms/')
      else
        raise Sinatra::NotFound
      end
    end

  end

end

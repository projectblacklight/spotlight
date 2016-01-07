module Spotlight
  module Concerns
    ###
    # Mixin to be included into controllers that provides a
    # method to check if a particular user exists in the site
    module UserExistable
      def exists
        # note: the messages returned are not shown to users and really only useful for debug, hence no translation necessary
        #  app uses html status code to act on response
        if Spotlight::Engine.user_class.where(email: exists_params).present?
          render json: { message: 'User exists' }
        else
          render json: { message: 'User does not exist' }, status: :not_found
        end
      end

      protected

      def exists_params
        params.require(:user)
      end
    end
  end
end

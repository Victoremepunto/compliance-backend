# frozen_string_literal: true

module Mutations
  module Profile
    # Mutation to edit any of the profile  attributes
    class Edit < BaseMutation
      graphql_name 'UpdateProfile'

      argument :id, ID, required: true
      argument :compliance_threshold, Float, required: true
      field :profile, Types::Profile, null: true

      def resolve(args)
        profile = Pundit.authorize(
          context[:current_user],
          ::Profile.find(args[:id]),
          :edit?
        )
        profile.update(args.to_h)
        { profile: profile }
      end
    end
  end
end

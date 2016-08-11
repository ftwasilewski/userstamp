module Ddb #:nodoc:
  module Userstamp
    # The plug-in will use columns named
    # <tt>created_by</tt> and <tt>updated_by</tt>.
    #
    # Extends the stamping functionality of ActiveRecord by automatically recording the model
    # responsible for creating, updating, and deleting the current object. See the Stamper
    # and Userstamp modules for further documentation on how the entire process works.
    module Stampable
      def self.included(base) #:nodoc:
        super

        base.extend(ClassMethods)
        base.class_eval do
          include InstanceMethods

          # Should ActiveRecord record userstamps? Defaults to true.
          class_attribute :record_userstamp
          self.record_userstamp = true

          # Which class is responsible for stamping? Defaults to :user.
          class_attribute :stamper_class_name

          # What column should be used for the creator stamp?
          class_attribute :creator_attribute

          # What column should be used for the creator type stamp?
          class_attribute :creator_type_attribute

          # What column should be used for the creator name stamp?
          class_attribute :creator_name_attribute

          # What column should be used for the updater stamp?
          class_attribute :updater_attribute

          self.stampable unless self.respond_to?('stampable')
        end
      end

      module ClassMethods
        # This method is automatically called on for all classes that inherit from
        # ActiveRecord, but if you need to customize how the plug-in functions, this is the
        # method to use. Here's an example:
        #
        #   class Post < ActiveRecord::Base
        #     stampable :stamper_class_name => :person,
        #               :creator_attribute  => :create_user,
        #               :updater_attribute  => :update_user,
        #   end
        #
        # The method will automatically setup all the associations,
        # and create <tt>before_validation</tt> callbacks for doing the stamping.
        def stampable(options = {})
          defaults = {
            :stamper_class_name => :user,
            :creator_attribute  => :created_by,
            :creator_type_attribute  => :created_by_type,
            :creator_name_attribute  => :created_by_full_name,
            :updater_attribute  => :updated_by,
          }.merge(options)

          self.stamper_class_name = defaults[:stamper_class_name].to_sym
          self.creator_attribute  = defaults[:creator_attribute].to_sym
          self.creator_type_attribute  = defaults[:creator_type_attribute].to_sym
          self.creator_name_attribute  = defaults[:creator_name_attribute].to_sym
          self.updater_attribute  = defaults[:updater_attribute].to_sym

          class_eval do
            before_validation :set_updater_attribute
            before_validation :set_creator_attribute, :on => :create
          end
        end

        # Temporarily allows you to turn stamping off. For example:
        #
        #   Post.without_stamps do
        #     post = Post.find(params[:id])
        #     post.update_attributes(params[:post])
        #     post.save
        #   end
        def without_stamps
          original_value = self.record_userstamp
          self.record_userstamp = false
          yield
        ensure
          self.record_userstamp = original_value
        end

        def stamper_class #:nodoc:
          stamper_class_name.to_s.camelize.constantize rescue nil
        end
      end

      module InstanceMethods #:nodoc:
        private
          def has_stamper?
            !self.class.stamper_class.nil? && !self.class.stamper_class.stamper.nil? rescue false
          end

          def set_creator_attribute
            return unless self.record_userstamp && has_stamper?

            if respond_to?(self.creator_attribute.to_sym) && self.send(self.creator_attribute.to_sym).blank?
              self[self.creator_attribute.to_sym] = self.class.stamper_class.stamper.id.to_s
            end

            if respond_to?(self.creator_type_attribute.to_sym) && self.send(self.creator_type_attribute).blank?
              self[self.creator_type_attribute.to_sym] = self.class.stamper_class.stamper.class.to_s
            end

            if respond_to?(self.creator_name_attribute.to_sym) && self.send(self.creator_name_attribute).blank? && self.class.stamper_class.stamper.respond_to?(:full_name)
              self[self.creator_name_attribute.to_sym] = self.class.stamper_class.stamper.full_name.to_s
            end
          end

          def set_updater_attribute
            return unless self.record_userstamp
            # only set updater if the record is new or has changed
            return unless self.new_record? || self.changed?
            if respond_to?(self.updater_attribute.to_sym) && has_stamper?
              self[self.updater_attribute.to_sym] = self.class.stamper_class.stamper.id.to_s
            end
          end
        #end private
      end
    end
  end
end

ActiveRecord::Base.send(:include, Ddb::Userstamp::Stampable) if defined?(ActiveRecord)

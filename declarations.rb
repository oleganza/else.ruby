module Declarations
  # Allows to store some declarations in a module and include them 
  # in many places. Actual evaluation happens in a context of receiver.
  # Deferred declarations can be included into another deferred declarations.
  # When deferred module is updated with new declarations, 
  # all children are updated.
  #
  # Example:
  #
  # module MyValidations
  #   extend Declarations::Deferred
  #   validates_length_of       :password, :within => 4..40, :if => :password_required?
  #   validates_confirmation_of :password,                   :if => :password_required?
  #   validates_length_of       :email,    :within => 3..100
  #   validates_uniqueness_of   :email, :case_sensitive => false
  # end
  #
  # class User < ActiveRecord::Base
  #   include MyValidations
  # end
  #
  module Deferred
    attr_accessor :declarations, :children
    # All DSLs are considered missing methods. 
    # TODO: remove standard methods from the module, 
    #       where this one is included (and make this includable).
    def method_missing(meth, *args, &blk)
      @declarations ||= []
      tuple = [meth, args, blk]
      # fight the reloading feature
      # FIXME: won't be okay with dynamically created objects and procs
      unless @declarations.include?(tuple) 
        @declarations << tuple
        (@children || []).each do |child|
          exec_decl(child, meth, args, blk)
        end
      end
    end
    def included(mod)
      @children ||= []
      unless @children.include?(mod) 
        @children << mod
        @declarations.each do |decl|
          exec_decl(mod, *decl)
        end
      end
    end
  private
    # Execute declaration on a object
    def exec_decl(object, meth, args, blk)
      object.send(meth, *args, &blk)
    end
  end

end

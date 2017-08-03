class User < ActiveRecord::Base
  model_stamper

  def full_name
    name
  end
end

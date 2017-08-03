require 'test/helper'

class StampingTests < ActiveSupport::TestCase  # :nodoc:
  setup do
    User.delete_all
    Person.delete_all
    Post.delete_all

    @zeus = User.create!(:name => 'Zeus')
    @hera = User.create!(:name => 'Hera')
    User.stamper = @zeus

    @delynn = Person.create!(:name => 'Delynn')
    @nicole = Person.create!(:name => 'Nicole')
    Person.stamper = @delynn

    @first_post = Post.create!(:title => 'a title')
  end

  test 'test_person_creation' do
    assert_equal @zeus, User.stamper

    person = Person.create(:name => 'David')

    assert_equal @zeus.id, person.created_by
    assert_equal @zeus.class.to_s, person.created_by_type
    assert_equal @zeus.full_name, person.created_by_full_name

    assert_equal @zeus.id, person.updated_by
    assert_equal @zeus.class.to_s, person.updated_by_type
  end

  test 'test_post_creation' do
    assert_equal @delynn, Person.stamper

    post = Post.create(:title => 'Test Post - 1')
    assert_equal @delynn.id, post.created_by
    assert_equal @delynn.id, post.updated_by
  end

  test 'test_person_updating_with_stamped_object' do
    User.stamper = @hera
    assert_equal @hera, User.stamper
    @delynn.name = 'Berry'
    @delynn.save
    @delynn.reload
    assert_equal @zeus.id, @delynn.created_by
    assert_equal @hera.id, @delynn.updated_by
  end

  test 'test_post_updating_with_stamped_object' do
    Person.stamper = @nicole
    assert_equal @nicole, Person.stamper

    @first_post.title = 'Updated'
    @first_post.save
    @first_post.reload
    assert_equal @delynn.id, @first_post.created_by
    assert_equal @nicole.id, @first_post.updated_by
  end
end

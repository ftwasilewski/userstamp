require 'test/helper'

class StampingTests < Test::Unit::TestCase  # :nodoc:
  def setup
    reset_to_defaults
    User.stamper = @zeus
    Person.stamper = @delynn
  end

  def test_person_creation_with_stamped_object
    assert_equal @zeus.id, User.stamper

    person = Person.create(:name => "David")
    assert_equal @zeus.id, person.created_by
    assert_equal @zeus.id, person.updated_by
    assert_equal @zeus, person.creator
    assert_equal @zeus, person.updater
  end

  def test_person_creation_with_stamped_integer
    User.stamper = @nicole.id
    assert_equal @nicole.id, User.stamper

    person = Person.create(:name => "Daniel")
    assert_equal @hera.id, person.created_by
    assert_equal @hera.id,  person.updated_by
    assert_equal @hera, person.creator
    assert_equal @hera, person.updater
  end

  def test_post_creation_with_stamped_object
    assert_equal @delynn.id, Person.stamper

    post = Post.create(:title => "Test Post - 1")
    assert_equal @delynn.id, post.created_by
    assert_equal @delynn.id, post.updated_by
    assert_equal @delynn, post.creator
    assert_equal @delynn, post.updater
  end

  def test_post_creation_with_stamped_integer
    Person.stamper = @nicole.id
    assert_equal @nicole.id, Person.stamper

    post = Post.create(:title => "Test Post - 2")
    assert_equal @nicole.id, post.created_by
    assert_equal @nicole.id, post.updated_by
    assert_equal @nicole, post.creator
    assert_equal @nicole, post.updater
  end

  def test_person_updating_with_stamped_object
    User.stamper = @hera
    assert_equal @hera.id, User.stamper
    @delynn.name = "Berry"
    @delynn.save
    @delynn.reload
    assert_equal @zeus, @delynn.creator
    assert_equal @hera, @delynn.updater
    assert_equal @zeus.id, @delynn.created_by
    assert_equal @hera.id, @delynn.updated_by
  end

  def test_person_updating_with_stamped_integer
    User.stamper = @hera.id
    assert_equal @hera.id, User.stamper

    @delynn.name = "Berry"
    @delynn.save
    @delynn.reload
    assert_equal @zeus.id, @delynn.created_by
    assert_equal @hera.id, @delynn.updated_by
    assert_equal @zeus, @delynn.creator
    assert_equal @hera, @delynn.updater
  end

  def test_post_updating_with_stamped_object
    Person.stamper = @nicole
    assert_equal @nicole.id, Person.stamper

    @first_post.title = "Updated"
    @first_post.save
    @first_post.reload
    assert_equal @delynn.id, @first_post.created_by
    assert_equal @nicole.id, @first_post.updated_by
    assert_equal @delynn, @first_post.creator
    assert_equal @nicole, @first_post.updater
  end

  def test_post_updating_with_stamped_integer
    Person.stamper = @nicole.id
    assert_equal @nicole.id, Person.stamper

    @first_post.title = "Updated"
    @first_post.save
    @first_post.reload
    assert_equal @delynn.id, @first_post.created_by
    assert_equal @nicole.id, @first_post.updated_by
    assert_equal @delynn, @first_post.creator
    assert_equal @nicole, @first_post.updater
  end
end

require File.dirname(__FILE__) + '/test_helper'

class RemoteS3ObjectTest < Test::Unit::TestCase
  def setup
    establish_real_connection
    Bucket.create(TEST_BUCKET)
    Bucket.create(TEST_BUCKET2)
  end
  
  def teardown
    # Bucket.delete(TEST_BUCKET)
    # Bucket.delete(TEST_BUCKET2)
    disconnect!
  end
  
  def test_copy_bucket_to_bucket
    key                 = 'testing_s3objects'
    value               = 'testing'
    content_type        = 'text/plain'
    unauthenticated_url = ['http:/', Base.connection.http.address, TEST_BUCKET, key].join('/')
    
    # Create an object
    
    response = nil
    assert_nothing_raised do
      response = S3Object.create(key, value, TEST_BUCKET, :access => :public_read, :content_type => content_type)
    end
    
    # Check response
    
    assert response.success?
    
    # Fetch newly created object to show it was actually created
    
    object = nil
    assert_nothing_raised do
      object = S3Object.find(key, TEST_BUCKET)
    end
    
    assert object
    
    key = object.key

    # Copy the object to a remote bucket
    
    assert_nothing_raised do
      object.copy('testing_s3objects-copy', :target_bucket => TEST_BUCKET2)
    end
    
    # Confirm the object is identical
    
    copy = nil
    assert_nothing_raised do
      copy = S3Object.find('testing_s3objects-copy', TEST_BUCKET2)
    end
    
    assert copy
    
    assert_equal object.value, copy.value
    assert_equal object.content_type, copy.content_type
    
    # Delete object
    
    assert_nothing_raised do
      object.delete
    end
    
  end
    
end
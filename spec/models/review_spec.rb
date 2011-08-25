# Notes for when writing the tests:
# #create_or_update_from_ios_client_data - should not update the review if the new timestamp is less than it's creation date
# - should test: anonymous review -> normal review conversion
# - should test: normal review, but login for it does not exists -> anonymous review gets registered -> anonymous review gets 
#   turned into normal after registration
# - should test that content can be empty (ratings)
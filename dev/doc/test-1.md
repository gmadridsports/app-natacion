    +--------------------|---------------+                      +---------------------------------+
    | Flutter source     | Patrol tests  |                      | Compiled test for ios/android   |
    |                    | sources       |                      | as an app, with user credential |                                      +----------------------+
    |--------------------|---------------|                      | to create test users            | <----generates a user--------------> | Supabase backend env | 
    | TestUserBuilder                    | -----compiles------> |---------------------------------|                                      | pointed by .test.env |
    | generates users on supabase when   |                      | Flutter compiled app with       | <----with generated test's user----> |                      |
    | a test calls it (runtime)          |         ^            | compile time .test.env values   |                                      +----------------------+
    |------------------------------------|         |            +---------------------------------+                                      | Test users framework |
    | Patrol lib                         |         |            | virtual device/connected dev    |                                      | to create/delete them|
    |------------------------------------|         |            +---------------------------------+                                      +----------------------+
    | dev/.test.env with env values      |         |            | Patrol client                   |                                      
    +------------------------------------+ a user's credentials +---------------------------------+
                                           of the supabase      /---------------------------------+
                                          pointed by .test.env  | local env with connected device |
                                           which is able to     | or firebase running the app     |
                                           create new users     | on a device                     |
                                                                +---------------------------------/
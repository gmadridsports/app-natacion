    +--------------------|---------------+               +---------------------------------+
    | Flutter source     | Patrol tests  |               | Compiled test for ios/android   |
    |                    | sources       |               | as an app                       |
    |--------------------|---------------|               |---------------------------------|         +----------------------+
    | Patrol lib                         | --compiles--> | Flutter compiled app with       | <-----> | Supabase backend env |
    |------------------------------------|               | compile time .test.env values   |         | pointed by .test.env |
    | dev/.test.env with env values      |               +---------------------------------+         +----------------------+
    + AND TEST ENV CREDENTIALS           |               | virtual device/connected dev    |
    +------------------------------------+               +---------------------------------+
                                                         | Patrol client                   |
                                                         +---------------------------------+

                                                         /---------------------------------+
                                                         | local env with connected device |
                                                         | or firebase running the app     |
                                                         | on a device                     |
                                                         +---------------------------------/    

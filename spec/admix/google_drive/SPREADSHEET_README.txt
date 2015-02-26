1- open ruby in the terminal (irb) while you're in admix directory (/admix)
2- type the following:
    > require_relitave "lib/google_drive_client_manager"
    > manager = AuthenticationManagerForInstalledAppClient.new(YOUR_CLIENT_ID, YOUR_CLIENT_SECRET, ANY_FILE_TO_WRITE_TO,
                                                                "admixmingle@gmail.com")
    > manager.access_token
3- This will prompt you to open a link, which is printed.
4- open the link to grant access to your client for "admixmingle@gmail.com" (or the email address you're using for your test)
5- Once granted, copy the authorisation code from the browser.
6- terminate `irb` (DO NOT PASTE IT HERE YET).
7- open `google_driver_spec.rb` and go to `GoogleSheetHelper` setup method.
8- Paste the code in the `before(:each)` method in `authorization_code` variable.
9- uncomment `allow_any_instance_of(AuthenticationManagerForInstalledAppClient).to receive(:gets).and_return(authorization_code)`
10- Run the test.
11- The test should pass (DO NOT RUN IT AGAIN YET).
12- Open `DO_NOT_OPEN_OR_CHANGE_ME.json` in assets.
13- Copy all the values of this file and paste them in the `before(:all)` for GoogleSheetHelper in `token_hash` variable.
14- Comment `allow_any_instance_of(AuthenticationManagerForInstalledAppClient).to receive(:gets).and_return(authorization_code)`
    , you do not need it anymore.
15- I think you're good to go now, sorry for the long process. If you can find an easier way to do all of that, please
    feel free to do it.
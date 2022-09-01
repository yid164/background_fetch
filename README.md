# background_fetch
## Learning background fetch of iOS development 

### Mock Server: 
* The `backend` folder, run the `main.go` in the terminal for start the localhost server
* The goal is helping iOS to count the requests when it is in background

### Swift: 
* Please change the url as your local ip in the `Endpoint.swift`
* Once the mock server started, the frontend will sent the request to the mock server, and the server would count it

### Test method: 

#### Hard simulation: 
* When the app is running, we can pause it, and on the debug console of the XCode, input: 
`e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.example.ken.process"]`
* Then resume the app, it will forcely simulate a background task 

#### Run and Wait:
* Run the app then wait for it, this way is very uneffient, but we can see how much time it would cost in the background process 

#### Simulator: 
* The `BackgroundTask` doesn't not support the simulator, so it has to run on the real devices 

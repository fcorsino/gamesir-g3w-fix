# gamesir-g3w-fix

All-in-one script to fix the issue with the [Gamesir G3w](https://www.gamesir.hk/pages/g3w-tutorial) controller on Linux, which does not register any event in its default mode of XBox360 clone.

This controller can work on 2 modes: XBox360 (clone) or Gamesir G3w. On Linux systems, it seems to start in XBox360 mode by default. Due to some issue on the xpad kernel module with XBox360 clones, the G3w is recognized but does not send any events.

Github user [dnmodder](https://github.com/dnmodder) found a solution to initialize properly the controller.
This script installs the script and the udev rules so that it is invoked automatically when the controller is connected.
You need to execute it with a user that can execute sudo or as root. The code is pretty straight forward, so I encourage you to check it first.

Check this thread for more details: https://github.com/paroj/xpad/issues/119

Thanks dnmodder, I had been chasing this problem for months.

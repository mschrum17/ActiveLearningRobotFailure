Matlab 2019b and Simulink are required to run the code. FlightGear 2018.2 is also required and must be installed from https://sourceforge.net/projects/flightgear/files/.
Open ALFlight3 and run the model.

The type of damage can be changed by changing the constant block connected to the Damage memory storage. 1=Wing Damage, 2=Vertical Stabilizer Damage, 3=Aileron Damage.
To change the reference for the airplane to track before the damage occurs, change the Initial Reference constant block.  
The values correspond to [horizontal velocity deviation from 160ft/s, roll angle, yaw angle, altitude deviation from 1000 ft].
The aircraft may not recover from all initial reference trajectories depending on configuration. For example if the airplane is tracking a 3 degree yaw angle and the wing is damgaed,
the aircraft may not recover.
If the airplane is tracking [10 0 0 0] initially and the wing is damaged, it can recover.
To change the reference for the airplane to track after damage occurs, change the Reference Damage block.
Damage is set to occur at 10 seconds.

module Physics.Types where

import Math.Vector3

--create body data type
--bodyID, mass, pos, vel
data Body = Body
 {bodyID::{-# UNPACK #-} !Int,
  mass::{-# UNPACK #-} !R,
  pos:: !Vector3,
  vel:: !Vector3
 }deriving(Eq)

--create show instance
instance Show Body where
 show (Body i m p v) = "Body ID " ++ show i ++ ", Mass " ++ showDouble m ++ ", Position " ++ show p ++ ", Velocity " ++ show v

--create body creation function
body::Int->R->Vector3->Vector3->Body
body = Body

--system state data
data SystemState = SystemState
 {time::{-# UNPACK #-} !R,
  bodies:: ![Body] --list of bodies
 }deriving(Eq)

--create show instance
instance Show SystemState where
 show (SystemState t bs) = "SystemState: t " ++ showDouble t ++ ", # Bodies " ++ (show $ length $ bs) ++ "\n" ++ unlines (map (\b -> "  " ++ show b) bs)
 --iterate over the body list and use the map feature

--create system state function
systemState::R->[Body]->SystemState
systemState = SystemState


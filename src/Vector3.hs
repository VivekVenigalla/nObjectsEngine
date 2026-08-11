{#-OPTIONS -WALL #-} --turns on warnings for any type conflicts

module Math.Vector3 where --define the file name and location so the .cabal file can find the module

type R :: Double --convert the Double into a new alias for real numbers

--create Vector3 Data object

data Vector3 = Vector3{ xComp :: R, --components
						yComp :: R,
						zComp :: R
					} deriving(Eq) --functions deriving for this data type(equals function)

--create a instance of the show class to allow for Vector3 printing

instance Show Vector3 where
	show (Vector3 x y z) = "vec" ++ showDouble x ++ " " ++ showDouble y ++ " " showDouble z

--create function showDouble
showDouble :: R->String --takes a real number and returns a string. if it is a negative number enclose in parantheses
showDouble x =
	| x < 0 = "(" ++ show x ++ ")"
	| otherwise = show x
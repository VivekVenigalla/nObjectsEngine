--{-# OPTIONS -WALL #-}since the cabal has the warnings turned on this is not needed


module Main (main) where
import Math.Vector3 --import Vector3 functions and types

main :: IO ()
main = do
	putStrLn "Hello, Haskell!"
	show Vec3 1 2 3

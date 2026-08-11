--{-# OPTIONS -WALL #-}since the cabal has the warnings turned on this is not needed


module Main (main) where
import Math.Vector3 --import Vector3 functions and types

main :: IO ()
main = do
    putStrLn "Hello, Haskell!"
    --let creates variables without side effects
    let v1 = vec3 1.0 2.0 3.0
        v2 = vec3 4.0 (-5.0) 6.0
        v3 = v1 ^+^ v2
        dot = v1 <.> v2
        cross = v1 >< v2

    putStrLn $ "v1: " ++ show v1
    putStrLn $ "v2: " ++ show v2
    putStrLn $ "v1 + v2: " ++ show v3
    putStrLn $ "v1 . v2: " ++ show dot
    putStrLn $ "v1 x v2: " ++ show cross

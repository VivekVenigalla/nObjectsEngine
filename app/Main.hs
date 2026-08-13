--{-# OPTIONS -WALL #-}since the cabal has the warnings turned on this is not needed


module Main (main) where

import Math.Vector3 --import Vector3 functions and types
import Physics.Types
import Physics.Forces
--import Physics.Integrator is not needed as we dont use those functions explicitly
import Physics.Simulator

import System.Directory --import function used in this code
import Text.Printf (printf)

main :: IO ()
main = do
    putStrLn "Running Main.hs"
    --let creates variables without side effects

    --Simulate the Earth Sun relation
    let sunMass = 1.981e30 --define physical constants
        earthMass = 5.9722e24
        dist = 1.496e11

        vEarth = sqrt (gravitationalConstant * (sunMass + earthMass) / dist)

        --create bodies
        sun = Body 1 sunMass (vec3 0 0 0) (vec3 0 0 0) --origin with zero initial velocity
        earth = Body 2 earthMass (vec3 dist 0 0) (vec3 0 vEarth 0) --along xAxis with vertical initial velocity

        initialState = SystemState 0.0 [sun, earth] --create initial state
    --default params for simulation
    let period = 2.0 * pi * sqrt ((dist*dist*dist)/(gravitationalConstant*(earthMass + sunMass)))
        steps = 1000
        dt = period / fromIntegral steps
        outputDir = "output/output.csv"

    createDirectoryIfMissing True "output"

    --execute simulation
    printf "Simulating %d steps (dt = %.2f s)...\n" steps dt
    writeSimToCSV outputDir gravitationalConstant defaultSoftening dt steps initialState
    printf "Trajectory saved to: %s\n" outputDir

    --energy logging
    let (_, energyDrift) = simAndEnergyLog gravitationalConstant defaultSoftening dt steps initialState
    printf "Relative Energy Drift: %.6e (%.4f%%)\n" energyDrift (energyDrift * 100)



    putStrLn "Simulation complete."


--{-# OPTIONS -WALL #-}since the cabal has the warnings turned on this is not needed


module Main (main) where

import Math.Vector3 --import Vector3 functions and types
import Physics.Types
import Physics.Forces
--import Physics.Integrator is not needed as we dont use those functions explicitly
import Physics.Simulator
import Physics.Presets

import System.Directory --import function used in this code
import Text.Printf (printf)

import Options.Applicative


--preset data type with necessary variables
--data Preset = Kepler | Figure8 | Plummer Int Int
data Config = Config
    { cfgPreset    :: String
    , cfgSteps     :: Int
    , cfgDt        :: Double
    , cfgOutFile   :: String
    , cfgNumBodies :: Int
    , cfgSeed      :: Int
    }

--create a Parser Config function that allows for modifying steps, preset, dt and more in the terminal
configParser :: Parser Config
configParser = Config
  <$> strOption
      ( long "preset"
     <> short 'p'
     <> metavar "PRESET"
     <> value "kepler"
     <> help "Simulation preset: kepler, figure8, or plummer (default: kepler)" )
  <*> option auto
      ( long "steps"
     <> short 's'
     <> metavar "INT"
     <> value 1000
     <> help "Number of integration steps (default: 1000)" )
  <*> option auto
      ( long "dt"
     <> metavar "FLOAT"
     <> value (-1.0)
     <> help "Time step size in seconds. If negative/omitted, auto-calculates from period or default." )
  <*> strOption
      ( long "output"
     <> short 'o'
     <> metavar "FILE"
     <> value "output/output.csv"
     <> help "Output CSV trajectory path (default: output/output.csv)" )
  <*> option auto
      ( long "bodies"
     <> short 'n'
     <> metavar "INT"
     <> value 100
     <> help "Number of bodies for Plummer sphere preset (default: 100)" )
  <*> option auto
      ( long "seed"
     <> metavar "INT"
     <> value 42
     <> help "RNG seed for Plummer generator (default: 42)" )


--initial state vars

getInitial :: Config -> (SystemState, Double, Double, Double)
getInitial cfg = case cfgPreset cfg of
  "figure8" ->
    let dt = if cfgDt cfg > 0 then cfgDt cfg else 0.001
    in (figure8, dt, 1.0, 0.0) --g = 1.0 and softening = 0.0 for this particular model
    
  "plummer" ->
    let state = plummerSphere (cfgNumBodies cfg) (cfgSeed cfg) 10.0
        dt = if cfgDt cfg > 0 then cfgDt cfg else 0.01
    in (state, dt, gravitationalConstant, defaultSoftening)
    
  _ -> --deafult kepler earth system(see previous commit)
    let m1 = 1.989e30
        m2 = 5.9722e24
        dist = 1.496e11
        vEarth = sqrt (gravitationalConstant * (m1 + m2) / dist)
        sun   = Body 1 m1 (vec3 0 0 0)    (vec3 0 0 0)
        earth = Body 2 m2 (vec3 dist 0 0) (vec3 0 vEarth 0)
        state = SystemState 0.0 [sun, earth]
        
        period = 2.0 * pi * sqrt ((dist * dist * dist) / (gravitationalConstant * (m1 + m2)))
        dt = if cfgDt cfg > 0 then cfgDt cfg else (period / fromIntegral (cfgSteps cfg))
    in (state, dt, gravitationalConstant, defaultSoftening)

--main loop
main :: IO ()
main = do
  cfg <- execParser $ info (configParser <**> helper) --get the command line arguments
    ( fullDesc
   <> progDesc "nObjectsEngine - High Performance N-Body Gravitational Physics Engine"
   <> header "nObjectsEngine CLI" )

  let (initialState, dt, g, eps) = getInitial cfg
      steps = cfgSteps cfg
      outPath = cfgOutFile cfg

  putStrLn "Running Main.hs"
  putStrLn "Presets"
  printf "Preset: %s | Bodies: %d | Steps: %d | dt: %.4e s\n"
    (cfgPreset cfg) (length $ bodies initialState) steps dt

  createDirectoryIfMissing True "output"

  writeSimToCSV outPath g eps dt steps initialState
  printf "Trajectory saved to: %s\n" outPath

  let (_, energyDrift) = simAndEnergyLog g eps dt steps initialState
  printf "Relative Energy Drift: %.6e (%.4f%%)\n" energyDrift (energyDrift * 100)
  putStrLn "Simulation complete."


module Physics.Presets where

import Math.Vector3
import Physics.Types


import System.Random --for random config generation

--generate prestes (figure 8 or plummer sphere)

--figure 8(3 body system with precise coordinates)
figure8::SystemState
figure8 =
    let m = 1.0 --all of these presets are from A remarkable periodic solution of the three-body problem in the case of equal masses by Chenciner & Montgomery (2000)
        x1 = -0.97000436
        y1 =  0.24308753
        v1x =  0.46620531
        v1y =  0.43236573

        p1 = vec3 x1 y1 0.0
        v1 = vec3 v1x v1y 0.0

        p2 = vec3 (-x1) (-y1) 0.0
        v2 = v1

        p3 = vec3 0.0 0.0 0.0
        v3 = vec3 (-2.0 * v1x) (-2.0 * v1y) 0.0

        body1 = Body 1 m p1 v1
        body2 = Body 2 m p2 v2
        body3 = Body 3 m p3 v3

    in SystemState 0.0 [body1, body2, body3]

plummerSphere:: Int->Int->R->SystemState --the first three is the total bodies, seed, and total radius

plummerSphere toBodies seed toRadius =
    let gen0 = mkStdGen seed
        (bs, _) = generateBodies toBodies 1 gen0 toRadius --call generateBodies with the seed number and numBodies and radius
    in SystemState 0.0 bs

generateBodies :: Int -> Int -> StdGen -> R -> ([Body], StdGen)
generateBodies 0 _ gen _ = ([], gen) --base case when numBodies = 0
generateBodies count currentId gen scaleR =
    let --samplle radius using inverse transform scaling and position determined with spherical coordinates
        (u1, gen1) = randomR (0.0, 0.999 :: Double) gen --the function randomR takes a seed as input and gives a new seed
        --sample radius = scaleR * (u1^(-2/3)-1)^-1/2
        r = scaleR / sqrt (u1 ** (-2.0 / 3.0) - 1.0)

        --pick two additional angles(isotropic)
        (u2, gen2) = randomR (0.0, 1.0 :: Double) gen1 --with each randomR we get a new seed to use
        (u3, gen3) = randomR (-1.0, 1.0 :: Double) gen2

        --convert angles into theta and pi
        theta = 2.0 * pi * u2
        phi = acos u3

        --determine position using the spherical coordinates
        px = r * sin phi * cos theta
        py = r * sin phi * sin theta
        pz = r * cos phi

        --escape velocity at r
        vEsc = sqrt (2.0 / sqrt (r * r + scaleR * scaleR))

        --use von neumann rejection to generate a velocity that can satisfy constraints
        (u4, gen4) = randomR (0.0, 1.0 :: Double) gen3
        (u5, gen5) = randomR (0.0, 1.0 :: Double) gen4

        vMag = vEsc * u4 * (u5 * 0.5) --scaled orbital speed

        (u6, gen6) = randomR (0.0, 1.0 :: Double) gen5
        (u7, gen7) = randomR (-1.0, 1.0 :: Double) gen6
        --determine speed angle
        vTheta = 2.0 * pi * u6
        vPhi = acos u7

        --convert spherical vector into cartesian
        vx = vMag * sin vPhi * cos vTheta
        vy = vMag * sin vPhi * sin vTheta
        vz = vMag * cos vPhi

        --create body
        bodyT = Body currentId 1.0 (vec3 px py pz) (vec3 vx vy vz)
        --recusively call the function until base case reaches
        (rest, finalGen) = generateBodies (count - 1) (currentId + 1) gen7 scaleR

    in (bodyT : rest, finalGen) --return body and final seed number


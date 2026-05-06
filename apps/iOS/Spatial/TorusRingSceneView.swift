import SceneKit
import SwiftUI

struct TorusRingSceneView: UIViewRepresentable {
    var progress: Double

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.backgroundColor = .black
        view.scene = context.coordinator.makeScene()
        view.autoenablesDefaultLighting = false
        view.antialiasingMode = .multisampling4X
        view.isPlaying = true
        context.coordinator.update(progress: progress)
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        context.coordinator.update(progress: progress)
    }

    final class Coordinator {
        private let rootNode = SCNNode()
        private let remainingNode = SCNNode()
        private let trackNode = SCNNode()

        func makeScene() -> SCNScene {
            let scene = SCNScene()
            scene.background.contents = UIColor.black

            rootNode.eulerAngles = SCNVector3(-0.82, 0, -0.28)
            scene.rootNode.addChildNode(rootNode)

            trackNode.geometry = Self.makeTubeArcGeometry(fraction: 1, radialSegments: 192, tubeSegments: 18)
            trackNode.geometry?.materials = [Self.trackMaterial()]
            rootNode.addChildNode(trackNode)

            remainingNode.geometry = Self.makeTubeArcGeometry(fraction: 1, radialSegments: 192, tubeSegments: 20)
            remainingNode.geometry?.materials = [Self.remainingMaterial()]
            rootNode.addChildNode(remainingNode)

            let camera = SCNNode()
            camera.camera = SCNCamera()
            camera.camera?.fieldOfView = 44
            camera.position = SCNVector3(0, 0, 4.4)
            camera.look(at: SCNVector3Zero)
            scene.rootNode.addChildNode(camera)

            let keyLight = SCNNode()
            keyLight.light = SCNLight()
            keyLight.light?.type = .area
            keyLight.light?.intensity = 760
            keyLight.light?.color = UIColor(red: 0.62, green: 0.82, blue: 1, alpha: 1)
            keyLight.position = SCNVector3(-2.4, 2.2, 3.1)
            scene.rootNode.addChildNode(keyLight)

            let rimLight = SCNNode()
            rimLight.light = SCNLight()
            rimLight.light?.type = .omni
            rimLight.light?.intensity = 360
            rimLight.light?.color = UIColor(red: 0.45, green: 0.3, blue: 1, alpha: 1)
            rimLight.position = SCNVector3(2.1, -1.4, 2.6)
            scene.rootNode.addChildNode(rimLight)

            let ambient = SCNNode()
            ambient.light = SCNLight()
            ambient.light?.type = .ambient
            ambient.light?.intensity = 90
            ambient.light?.color = UIColor(red: 0.18, green: 0.22, blue: 0.32, alpha: 1)
            scene.rootNode.addChildNode(ambient)

            let spin = CABasicAnimation(keyPath: "rotation")
            spin.fromValue = NSValue(scnVector4: SCNVector4(0, 1, 0, 0))
            spin.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))
            spin.duration = 22
            spin.repeatCount = .infinity
            rootNode.addAnimation(spin, forKey: "timebite-ring-spin")

            return scene
        }

        func update(progress: Double) {
            let remaining = max(0.02, min(1, 1 - progress))
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.16
            remainingNode.geometry = Self.makeTubeArcGeometry(
                fraction: remaining,
                radialSegments: max(12, Int(remaining * 192)),
                tubeSegments: 20
            )
            remainingNode.geometry?.materials = [Self.remainingMaterial()]
            SCNTransaction.commit()
        }

        private static func remainingMaterial() -> SCNMaterial {
            let material = SCNMaterial()
            material.diffuse.contents = UIColor(red: 0.04, green: 0.6, blue: 1, alpha: 0.88)
            material.emission.contents = UIColor(red: 0.02, green: 0.24, blue: 0.66, alpha: 1)
            material.specular.contents = UIColor.white
            material.transparency = 0.9
            material.blendMode = .alpha
            material.lightingModel = .physicallyBased
            material.metalness.contents = 0.16
            material.roughness.contents = 0.18
            material.isDoubleSided = true
            return material
        }

        private static func trackMaterial() -> SCNMaterial {
            let material = SCNMaterial()
            material.diffuse.contents = UIColor(red: 0.36, green: 0.25, blue: 0.86, alpha: 0.28)
            material.emission.contents = UIColor(red: 0.08, green: 0.04, blue: 0.2, alpha: 1)
            material.specular.contents = UIColor(red: 0.5, green: 0.64, blue: 1, alpha: 1)
            material.transparency = 0.38
            material.blendMode = .alpha
            material.lightingModel = .physicallyBased
            material.metalness.contents = 0.08
            material.roughness.contents = 0.3
            material.isDoubleSided = true
            return material
        }

        private static func makeTubeArcGeometry(
            fraction: Double,
            radialSegments: Int,
            tubeSegments: Int
        ) -> SCNGeometry {
            let clampedFraction = max(0.01, min(1, fraction))
            let majorRadius: Float = 1.22
            let tubeRadius: Float = 0.18
            let sweep = Float.pi * 2 * Float(clampedFraction)
            let radialCount = max(3, radialSegments)
            let tubeCount = max(6, tubeSegments)
            var vertices: [SCNVector3] = []
            var normals: [SCNVector3] = []
            var indices: [Int32] = []

            for radialIndex in 0...radialCount {
                let u = sweep * Float(radialIndex) / Float(radialCount) - Float.pi / 2
                let center = SCNVector3(majorRadius * cos(u), majorRadius * sin(u), 0)
                let radialNormal = SCNVector3(cos(u), sin(u), 0)

                for tubeIndex in 0..<tubeCount {
                    let v = Float.pi * 2 * Float(tubeIndex) / Float(tubeCount)
                    let normal = SCNVector3(radialNormal.x * cos(v), radialNormal.y * cos(v), sin(v))
                    vertices.append(
                        SCNVector3(
                            center.x + tubeRadius * normal.x,
                            center.y + tubeRadius * normal.y,
                            tubeRadius * normal.z
                        )
                    )
                    normals.append(normal)
                }
            }

            for radialIndex in 0..<radialCount {
                for tubeIndex in 0..<tubeCount {
                    let nextTubeIndex = (tubeIndex + 1) % tubeCount
                    let a = Int32(radialIndex * tubeCount + tubeIndex)
                    let b = Int32((radialIndex + 1) * tubeCount + tubeIndex)
                    let c = Int32((radialIndex + 1) * tubeCount + nextTubeIndex)
                    let d = Int32(radialIndex * tubeCount + nextTubeIndex)
                    indices.append(contentsOf: [a, b, d, b, c, d])
                }
            }

            let vertexSource = SCNGeometrySource(vertices: vertices)
            let normalSource = SCNGeometrySource(normals: normals)
            let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<Int32>.size)
            let element = SCNGeometryElement(
                data: indexData,
                primitiveType: .triangles,
                primitiveCount: indices.count / 3,
                bytesPerIndex: MemoryLayout<Int32>.size
            )
            return SCNGeometry(sources: [vertexSource, normalSource], elements: [element])
        }
    }
}

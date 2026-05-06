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
        view.allowsCameraControl = true
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
        private let ghostNode = SCNNode()
        private let progressLabelNode = SCNNode()

        func makeScene() -> SCNScene {
            let scene = SCNScene()
            scene.background.contents = UIColor.black

            rootNode.eulerAngles = SCNVector3(-0.82, 0.0, -0.28)
            rootNode.scale = SCNVector3(1.18, 1.18, 1.18)
            scene.rootNode.addChildNode(rootNode)

            ghostNode.geometry = Self.makeTubeArcGeometry(fraction: 1.0, radialSegments: 192, tubeSegments: 18)
            ghostNode.geometry?.materials = [Self.ghostMaterial()]
            rootNode.addChildNode(ghostNode)

            remainingNode.geometry = Self.makeTubeArcGeometry(fraction: 0.65, radialSegments: 160, tubeSegments: 20)
            remainingNode.geometry?.materials = [Self.remainingMaterial()]
            rootNode.addChildNode(remainingNode)

            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.camera?.fieldOfView = 45
            cameraNode.position = SCNVector3(0, 0.0, 4.2)
            cameraNode.look(at: SCNVector3Zero)
            scene.rootNode.addChildNode(cameraNode)

            let keyLight = SCNNode()
            keyLight.light = SCNLight()
            keyLight.light?.type = .area
            keyLight.light?.intensity = 820
            keyLight.light?.color = UIColor(red: 0.62, green: 0.82, blue: 1.0, alpha: 1)
            keyLight.light?.areaType = .rectangle
            keyLight.light?.areaExtents = simd_float3(4.0, 4.0, 1.0)
            keyLight.position = SCNVector3(-2.4, 2.4, 3.2)
            scene.rootNode.addChildNode(keyLight)

            let rimLight = SCNNode()
            rimLight.light = SCNLight()
            rimLight.light?.type = .omni
            rimLight.light?.intensity = 420
            rimLight.light?.color = UIColor(red: 0.52, green: 0.26, blue: 1.0, alpha: 1)
            rimLight.position = SCNVector3(2.2, -1.4, 2.5)
            scene.rootNode.addChildNode(rimLight)

            let ambient = SCNNode()
            ambient.light = SCNLight()
            ambient.light?.type = .ambient
            ambient.light?.intensity = 95
            ambient.light?.color = UIColor(red: 0.15, green: 0.22, blue: 0.34, alpha: 1)
            scene.rootNode.addChildNode(ambient)

            let spin = CABasicAnimation(keyPath: "rotation")
            spin.fromValue = NSValue(scnVector4: SCNVector4(0, 1, 0, 0))
            spin.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))
            spin.duration = 18
            spin.repeatCount = .infinity
            rootNode.addAnimation(spin, forKey: "slow-spin")

            return scene
        }

        func update(progress: Double) {
            let remaining = max(0.02, min(1.0, 1.0 - progress))
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.18
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
            material.diffuse.contents = UIColor(red: 0.05, green: 0.62, blue: 1.0, alpha: 0.92)
            material.emission.contents = UIColor(red: 0.02, green: 0.28, blue: 0.70, alpha: 1.0)
            material.specular.contents = UIColor.white
            material.shininess = 0.95
            material.transparency = 0.92
            material.blendMode = .alpha
            material.lightingModel = .physicallyBased
            material.metalness.contents = 0.18
            material.roughness.contents = 0.18
            material.isDoubleSided = true
            return material
        }

        private static func ghostMaterial() -> SCNMaterial {
            let material = SCNMaterial()
            material.diffuse.contents = UIColor(red: 0.34, green: 0.20, blue: 0.96, alpha: 0.34)
            material.emission.contents = UIColor(red: 0.10, green: 0.04, blue: 0.28, alpha: 1.0)
            material.specular.contents = UIColor(red: 0.45, green: 0.62, blue: 1.0, alpha: 1.0)
            material.shininess = 0.7
            material.transparency = 0.42
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
            let clampedFraction = max(0.01, min(1.0, fraction))
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

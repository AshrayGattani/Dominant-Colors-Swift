import UIKit

struct KMeans {
    let k: Int
    
    init(k: Int) {
        self.k = k
    }
    
    func clusterColors(_ colors: [UIColor]) -> [UIColor] {
        // Convert UIColor to RGB
        let rgbColors = colors.map { color -> [CGFloat] in
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            return [red, green, blue]
        }
        
        // Run K-Means algorithm
        let kmeans = KMeansAlgorithm(k: k, data: rgbColors)
        let dominantColors = kmeans.cluster()
        
        // Convert back to UIColor
        return dominantColors.map { colorArray in
            UIColor(red: colorArray[0], green: colorArray[1], blue: colorArray[2], alpha: 1.0)
        }
    }
}

// K-Means Algorithm
struct KMeansAlgorithm {
    let k: Int
    let data: [[CGFloat]]
    private var centroids: [[CGFloat]]
    
    init(k: Int, data: [[CGFloat]]) {
        self.k = k
        self.data = data
        self.centroids = Array(repeating: [CGFloat](repeating: 0.0, count: 3), count: k)
    }
    
    func cluster() -> [[CGFloat]] {
        var points = data
        var centroids = initializeCentroids(data: data)
        
        var changed = true
        while changed {
            let clusters = assignClusters(points: points, centroids: centroids)
            let newCentroids = updateCentroids(clusters: clusters)
            changed = !areCentroidsEqual(newCentroids, centroids)
            centroids = newCentroids
        }
        
        return centroids
    }
    
    private func initializeCentroids(data: [[CGFloat]]) -> [[CGFloat]] {
        return (0..<k).map { _ in
            let randomIndex = Int.random(in: 0..<data.count)
            return data[randomIndex]
        }
    }
    
    private func assignClusters(points: [[CGFloat]], centroids: [[CGFloat]]) -> [[Int]] {
        var clusters = Array(repeating: [Int](), count: k)
        
        for (index, point) in points.enumerated() {
            let closestCentroidIndex = centroids.indices.min(by: { distance(point, centroids[$0]) < distance(point, centroids[$1]) })!
            clusters[closestCentroidIndex].append(index)
        }
        
        return clusters
    }
    
    private func updateCentroids(clusters: [[Int]]) -> [[CGFloat]] {
        return (0..<k).map { clusterIndex in
            let clusterPoints = clusters[clusterIndex].map { index in
                return data[index]
            }
            let sum = clusterPoints.reduce([CGFloat](repeating: 0.0, count: 3)) { sum, point in
                zip(sum, point).map(+)
            }
            let count = CGFloat(clusterPoints.count)
            return sum.map { $0 / count }
        }
    }
    
    private func distance(_ a: [CGFloat], _ b: [CGFloat]) -> CGFloat {
        return zip(a, b).map { ($0 - $1) * ($0 - $1) }.reduce(0, +).squareRoot()
    }
    
    private func areCentroidsEqual(_ a: [[CGFloat]], _ b: [[CGFloat]]) -> Bool {
        return zip(a, b).allSatisfy { zip($0, $1).allSatisfy { abs($0 - $1) < 0.001 } }
    }
}

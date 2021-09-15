#include <FastSAHKDTreeFactory.h>
#include <surfaceinspector/maths/Histogram.hpp>

using SurfaceInspector::maths::Histogram;

// ***  SAH UTILS  *** //
// ******************* //
double FastSAHKDTreeFactory::findSplitPositionBySAH(
    KDTreeNode *node,
    vector<Primitive *> &primitives
) const {
    /*
     * Code below is commented because it might be necessary in the future.
     * If problems are found with the fast SAH implementation, notice that it
     *  is a well known issue that the min-max method might cause problems at
     *  nodes where number of primitives is smaller than the number of bins.
     *  In such cases, it is recommended to use the full SAH computation
     *  instead of the min-max approximation.
     */
    // If there are not enough primitives, use a more accurate loss computation
    /*if(primitives.size() <= numBins)
        return SAHKDTreeFactory::findSplitPositionBySAH(node, primitives);*/

    // Extract min and max vertices in the same discrete space
    vector<double> minVerts, maxVerts;
    double const minp = node->bound.getMin()[node->splitAxis];
    double const maxp = node->bound.getMax()[node->splitAxis];
    for(Primitive *primitive : primitives){
        double const minq = primitive->getAABB()->getMin()[node->splitAxis];
        double const maxq = primitive->getAABB()->getMax()[node->splitAxis];
        minVerts.push_back((minq < minp) ? minp : minq);
        maxVerts.push_back((maxq > maxp) ? maxp : maxq);
    }
    Histogram<double> Hmin(minp, maxp, minVerts, numBins, false, false);
    Histogram<double> Hmax(minp, maxp, maxVerts, numBins, false, false);

    // Approximated discrete search of optimal splitting plane
    size_t NoLr = 0;
    size_t NoRr = primitives.size();
    double loss = (double) NoRr, newLoss;
    node->splitPos = Hmin.a[0];
    double const rDenom = (double) numBins;
    for(size_t i = 1 ; i <= numBins ; ++i){
        double const r = ((double)i) / rDenom;
        NoLr += Hmin.c[i-1];
        NoRr -= Hmax.c[i-1];
        newLoss = r*((double)NoLr) + (1.0-r)*((double)NoRr);
        if(newLoss < loss){
            loss = newLoss;
            node->splitPos = Hmin.b[i-1];
        }
    }

    // Store loss if requested
    return loss;
}

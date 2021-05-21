function linearInterp(imgcol, frame, nodata){
    frame  = frame  || 32;
    nodata = nodata || 0;

    // var frame = 32;
    var time   = 'system:time_start';
    imgcol = imgcol.map(addTimeBand);
    
    // We'll look for all images up to 32 days away from the current image.
    var maxDiff = ee.Filter.maxDifference(frame * (1000*60*60*24), time, null, time);
    var cond    = {leftField:time, rightField:time};
    
    // Images after, sorted in descending order (so closest is last).
    //var f1 = maxDiff.and(ee.Filter.lessThanOrEquals(time, null, time))
    var f1 = ee.Filter.and(maxDiff, ee.Filter.lessThanOrEquals(cond));
    var c1 = ee.Join.saveAll({matchesKey:'after', ordering:time, ascending:false})
        .apply(imgcol, imgcol, f1);
    
    // Images before, sorted in ascending order (so closest is last).
    //var f2 = maxDiff.and(ee.Filter.greaterThanOrEquals(time, null, time))
    var f2 = ee.Filter.and(maxDiff, ee.Filter.greaterThanOrEquals(cond));
    var c2 = ee.Join.saveAll({matchesKey:'before', ordering:time, ascending:true})
        .apply(c1, imgcol, f2);
    
    
    var interpolated = ee.ImageCollection(c2.map(function(img) {
        img = ee.Image(img);

        var before = ee.ImageCollection.fromImages(ee.List(img.get('before'))).mosaic();
        var after  = ee.ImageCollection.fromImages(ee.List(img.get('after'))).mosaic();
        
        img = img.set('before', null).set('after', null);
        // constrain after or before no NA values, confirm linear Interp having result
        before = replace_mask(before, after, nodata);
        after  = replace_mask(after , before, nodata);
        
        // Compute the ratio between the image times.
        var x1 = before.select('time').double();
        var x2 = after.select('time').double();
        var now = ee.Image.constant(img.date().millis()).double();
        var ratio = now.subtract(x1).divide(x2.subtract(x1));  // this is zero anywhere x1 = x2
        // Compute the interpolated image.
        before = before.select(0); //remove time band now;
        after  = after.select(0);
        img    = img.select(0); 
        
        var interp = after.subtract(before).multiply(ratio).add(before);
        // var mask   = img.select([0]).mask();
        
        var qc = img.mask().not().rename('qc');
        interp = replace_mask(img, interp, nodata);
        // Map.addLayer(interp, {}, 'interp');
        return interp.addBands(qc).copyProperties(img, img.propertyNames());
    }));
    return interpolated;
}

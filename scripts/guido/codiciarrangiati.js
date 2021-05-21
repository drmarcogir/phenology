// Load MODIS NDVI imagery.
var collection = ee.ImageCollection('MODIS/006/MOD09A1').filterDate('2000-01-01', '2020-12-31');

// var pkg_trend = require('users/kongdd/public:Math/pkg_trend.js');
var pkg_smooth = require('users/kongdd/public:Math/pkg_smooth.js');


function add_dn(IncludeYear, n) {
      return function(img){
        return add_dn_date(img, img.get('system:time_start'), IncludeYear, n);   
    };
}

function add_dn_date(img, beginDate, IncludeYear, n){
    beginDate = beginDate || img.get('system:time_start');
    if (IncludeYear === undefined) { IncludeYear = true; }
    n = n || 8;

    beginDate = ee.Date(beginDate);
    var year  = beginDate.get('year');
    var month = beginDate.get('month');

    var diff  = beginDate.difference(ee.Date.fromYMD(year, 1, 1), 'day').add(1);
    var dn    = diff.subtract(1).divide(n).floor().add(1).int();
    
    var yearstr  = year.format('%d'); //ee.String(year);
    dn   = dn.format('%02d'); //ee.String(dn);
    dn   = ee.Algorithms.If(IncludeYear, yearstr.cat("-").cat(dn), dn);
    // dn = ee.Number(dn)
    return ee.Image(img)
        .set('system:time_start', beginDate.millis())
        // .set('system:time_end', beginDate.advance(1, 'day').millis())
        .set('date', beginDate.format('yyyy-MM-dd')) // system:id
        .set('Year', yearstr)
        .set('Month', beginDate.format('MM'))
        .set('YearMonth', beginDate.format('YYYY-MM'))
        .set('dn', dn); //add dn for aggregated into 8days
}



collection = collection.map(add_dn(false, 8))
 
 
 
Map.addLayer(Rectangle1)


var MakMarco = ee.Image("users/marcogirardello/phenoutils/mask_unchanged_500m");


Map.addLayer(MakMarco,{min:0, max:1})


var palette = [ 'FFFFFF', 'CE7E45', 'DF923D', 'F1B555', 'FCD163', '99B718',
               '74A901', '66A000', '529400', '3E8601', '207401', '056201',
               '004C00', '023B01', '012E01', '011D01', '011301'];


///// set date
var start_date = ee.Date.fromYMD(2001, 1, 1);
var end_date   = ee.Date.fromYMD(2019, 12, 31);



print('MOD09GA is...',collection.limit(92))


// var prV = ee.String('01')
// var prova = collection.filterMetadata('dn', 'equals',prV )
// print('prova is...',prova.limit(92))


// Use this function to add variables for NDVI
var addNDVI = function(image) {
  // Return the image with the added bands.
    image = image.updateMask(MakMarco.eq(1))

  return image.addBands(image.normalizedDifference(['sur_refl_b02', 'sur_refl_b01']).rename('NDVI')).float();
  };
 
/**
 * Returns an image containing just the specified QA bits.
 *
 * Args:
 *   image - The QA Image to get bits from.
 *   start - The first bit position, 0-based.
 *   end   - The last bit position, inclusive.
 *   name  - A name for the output image.
 */ // function to get the MODIS QA flags
var getQABits = function(image, start, end, newName) {
    // Compute the bits we need to extract.
    var pattern = 0;
    for (var i = start; i <= end; i++) {
       pattern += Math.pow(2, i);
    }
    return image.select([0], [newName])
                  .bitwiseAnd(pattern)
                  .rightShift(start);
};

// function to mask out based on flags 
var maskPixels = function(image0) {
  // Select the QA band
  var QA = image0.select('StateQA');

  // Get the land_water_flag bits.
  var landWaterFlag = getQABits(QA, 3, 5, 'land_water_flag');

  // Get the cloud_state bits and find cloudy areas.
  var cloud = getQABits(QA, 0, 1, 'cloud_state').expression("b(0) == 1 || b(0) == 2");
  // Get the cloud_shadow bit
  var cloudShadows = getQABits(QA, 2, 2, 'cloud_shadow');
  // Get the Pixel is adjacent to cloud bit
  var cloudAdjacent = getQABits(QA, 13, 13, 'cloud_adj');
  // Get the internal cloud flag
  var cloud2 = getQABits(QA, 10, 10, 'cloud_internal');
                
  // Get the internal fire flag
  var fire = getQABits(QA, 11, 11, 'fire_internal');

  // Get the MOD35 snow/ice flag
  var snow1 = getQABits(QA, 12, 12, 'snow_MOD35');
  // Get the internal snow flag
  var snow2 = getQABits(QA, 15, 15, 'snow_internal');

  // Create a mask that filters out undesired areas
  var mask = landWaterFlag.eq(1)
            .and(cloud.not()).and(cloudShadows.not()).and(cloudAdjacent.not()).and(cloud2.not())
            .and(fire.not())
            .and(snow1.not()).and(snow2.not());

  return image0.updateMask(mask);
 // return mask;
}


var MOD09masked = collection.filterDate(start_date, end_date).map(maskPixels);



// Mask flags
var MOD09ndvi = MOD09masked.map(addNDVI).select('NDVI');

// print(MOD09ndvi)




// var MOD09ndvi = MOD09ndvi.map(function(image) {
//     image = image.updateMask(image.gt(0.1))
//     return image//.unmask();
// });



// Loop the years...
for(var year=2001; year< 2016; year++) { // 2019
// var year = 2002;


var yearp5 = ee.Number(year).add(5)

var start_date = ee.Date.fromYMD(year,1,1);
var end_date = ee.Date.fromYMD(yearp5,12,31);



var MOD09ndviY = MOD09ndvi.filterDate(start_date, end_date)


var MinNDVI = MOD09ndviY.min()
// print('MOD09ndviY',MOD09ndviY)

// %%% CLIMATOLOGY 5 years

// composite mensili


  var seasons= ee.ImageCollection.fromImages(
    ee.List(['01', '02', '03', '04', '05',
    '06', '07', '08', '09', '10','11','12',
    '13', '14', '15',
    '16', '17', '18', '19', '20','21','22',
    '23', '24', '25',
    '26', '27', '28', '29', '30','31','32',
    '33', '34', '35',
    '36', '37', '38', '39', '40','41','42',
    '43', '44', '45','46']).map(function(month){
  month = ee.String(month)
  var seqNDVI = MOD09ndviY
  .filterMetadata('dn', 'equals',month );
  return seqNDVI.median()
 .copyProperties(seqNDVI.first(), ['system:time_start','system:time_end','dn'])
  // .filter(ee.Filter.calendarRange(month, month.add(0),'month'))
    }))
  

var frame  = 8*10; 
var nodata = -9999; // missing values. It's crucial. Has to been given.

// two bands return: [band, qc];
// qc: 1 means linear interpolation; 0 means not;
var seasons2 = pkg_smooth.linearInterp(seasons, frame, nodata);

// var MaxNDVI_10 = MOD09ndviY.max().divide(10);

// MOD09ndviY = MOD09ndviY.map(function(image){
//   return image.updateMask(image.gte(MaxNDVI_10));
// });


// print(seasons)

// Map.addLayer(seasons,
//     {}, 'NDVI coll ',0);



var count_valid = seasons2.select('qc').count()



var smoothed = seasons2.map(function(image){
  image = image.select('NDVI')
  image = image.unmask()
  image = image.where(image.eq(0),MinNDVI);
    return image.updateMask(count_valid.gte(20))
    //return image.updateMask(image.select('NDVI').gt(0))
    })



//smoothed = smoothed.map(function(image){
 //   return image.unmask()
//})

// Map.addLayer(smoothed,
//     {}, 'smoothed coll ',0);








// print(c.filter(ee.Filter.listContains('system:band_names', 'band1')))
smoothed = smoothed.select('NDVI')



// Define reference conditions from the first  year of data.
// var reference = smoothed
//   // Sort chronologically in descending order.
//   .sort('system:time_start', true);


// Display cumulative NDVI.
// Map.setCenter(-100.811, 40.2, 5);
// Map.addLayer(reference.sum(),
//     {min: 0, max: 100, palette: palette}, 'mean ',0);

// Get the timestamp from the most recent image in the reference collection.
var time0 = smoothed.first().get('system:time_start');
// print(time0)

// Use imageCollection.iterate() to make a collection of cumulative NDVI over time.

var first = ee.List([
  // Rename the first band 'NDVI'.
  ee.Image(0).set('system:time_start', time0).select([0], ['NDVI']).toFloat()
]);


// print(first)


// reference = reference
//   // Sort chronologically in descending order.
//   .sort('system:time_start', true);

// Map.addLayer(ee.Image(first.get(0)),{},'NDVI 0')

// This is a function to pass to Iterate().
// As NDVI images are computed, add them to the list.
var accumulate = function(image, list) {
  // Get the latest cumulative NDVI of the list with
  // get(-1).  Since the type of the list argument to the function is unknown,
  // it needs to be cast to a List.  Since the return type of get() is unknown,
  // cast it to Image.
  var previous = ee.Image(ee.List(list).get(-1)).toFloat();
  // Add the current anomaly to make a new cumulative NDVI image.
  var added = image.toFloat().add(previous).toFloat()
    // Propagate metadata to the new image.
    .set('system:time_start', image.get('system:time_start'));
  // Return the list with the cumulative NDVI inserted.
  return ee.List(list).add(added);
};

// Create an ImageCollection of cumulative anomaly images by iterating.
// Since the return type of iterate is unknown, it needs to be cast to a List.
var cumulative = ee.ImageCollection(ee.List(smoothed.iterate(accumulate, first)));


// print('cumulative is',cumulative)



// var last = cumulative.max()//filterDate('2011-12-30', '2011-12-31').first()// Sort chronologically in descending order.
  // sort('system:time_start', false).first();



/////////// For Marco -< added new code!!!
/////////// NORMALIZE
var last = cumulative.sort('system:time_start', false).first();
last = last.updateMask(last.gte(1.5))
/////////// For Marco -< added new code!!!




Map.addLayer(last, {min: 0, max: 30, palette: palette}, 'NDVI sum 2');


var cumulativeNorm = cumulative.map(function(image){
    return image.divide(last)
})

print('cumulativeNorm is',cumulativeNorm)
// 


var cumulativeStd10 = cumulativeNorm.map(function(image){
  var image10 = image.select('NDVI').reproject({
 crs: 'SR-ORG:6974',
    scale: 463.3127165275
  }).reduceNeighborhood({
  reducer:'stdDev',
  kernel: ee.Kernel.square(6, 'pixels'),
  skipMasked: true}).rename('stdDev')
  return image10
})

// .map(function(image){
//   var image10 = image.select('mean').reduceNeighborhood({
//   reducer:'stdDev',
//   kernel: ee.Kernel.square(6, 'pixels'),
//   skipMasked: true}).rename('stdDev')
//   return image10
// })
//band is mean_mean

//print('cumulativeStd10 is',cumulativeStd10)
var cumulativeStd10_mean = cumulativeStd10.mean().multiply(10000)
//print('cumulativeStd10_mean is',cumulativeStd10_mean)


/////////// For Marco -< added new code!!!

cumulativeStd10_mean = cumulativeStd10_mean.updateMask(last.gte(9))


var cumulativeStd10_mean_at_5km = cumulativeStd10_mean.reproject({
 crs: 'SR-ORG:6974',
    scale: 463.3127165275
  })
  .reduceResolution(ee.Reducer.mean(), false, 65536) 
  .reproject(ee.Projection('EPSG:4326').scale(0.05, 0.05)).updateMask(1) 
/////////// For Marco -< added new code!!!


print(cumulativeStd10_mean_at_5km)



Map.addLayer(cumulativeStd10_mean_at_5km, {min: 0, max: 5, palette: palette}, 'cumulativeStd10_mean_at_5km');
/////// tentative part to find when the 50th percentile is exceeded

// print(SD_DOY)

/*
Export.image.toDrive({
  image: cumulativeStd10_mean_at_5km,
  folder : 'Marco',
  description: 'cumulativeStd10_mean_at_5km_'+year,
crs: 'EPSG:4326',
  region: Rectangle1,
  maxPixels: 1e13,
  scale:'5565.974539663679' 
})
*/


Export.image.toAsset({
  image: cumulativeStd10_mean_at_5km,
  assetId : 'TestMarco/cumulativeStd10_mean_at_5km_'+year,
  description: 'cumulativeStd10_mean_at_5km_'+year,
 crs: 'EPSG:4326',
  region: Rectangle1,
  maxPixels: 1e13,
  scale:'5565.974539663679' 
   // scale: ee.Projection('EPSG:4326').nominalScale().divide(4*5).getInfo()

})

/*

if (year==2001) {
  var Final_output_ = ee.Image(cumulativeStd10_mean.select(['stdDev_mean']))
} else if(year<2018) {
  Final_output_ = Final_output_.addBands(cumulativeStd10_mean.select(['stdDev_mean']))
} else if(year == 2018){
  
    Final_output_ = Final_output_.addBands(cumulativeStd10_mean.select(['stdDev_mean']))

}

*/

}



/*

print(Final_output_)


Final_output_ = ee.Image(Final_output_)

var Final_output_Collection = ee.ImageCollection(Final_output_.bandNames().map(function(b) {
  return Final_output_.select([b]).rename('value');
}))


// #### standard deviation

 var SD_DOYMedian = Final_output_Collection.median()//##.reproject(MODISProjection.atScale(scale))

SD_DOYMedian = ee.Image(SD_DOYMedian)

Export.image.toDrive({
  image: SD_DOYMedian,
  folder : 'Marco',
  description: 'ratioNDVICumMeanMedian',
 crs: 'EPSG:4326',
  region: Rectangle1,
  maxPixels: 1e13,
  scale:'5565.974539663679' 
})



/// first three years

var mylist = [
  '0','1','2'
];

var FirstFinal_output_Collection = Final_output_Collection.
        filter(ee.Filter.inList('system:index',mylist))
print(FirstFinal_output_Collection)


//// last three years
var mylist = [
  '15','16','17'
];
var LastFinal_output_Collection = Final_output_Collection.
        filter(ee.Filter.inList('system:index',mylist))
print(LastFinal_output_Collection)




 var FirstFinal_output_CollectionMedian = FirstFinal_output_Collection.median()//##.reproject(MODISProjection.atScale(scale))

FirstFinal_output_CollectionMedian = ee.Image(FirstFinal_output_CollectionMedian)

Export.image.toDrive({
  image: FirstFinal_output_CollectionMedian,
  folder : 'Marco',
  description: 'FirstratioNDVICumMean',
 crs: 'EPSG:4326',
  region: Rectangle1,
  maxPixels: 1e13,
  scale:'5565.974539663679' 
})


 var LastFinal_output_CollectionMedian = LastFinal_output_Collection.median()//##.reproject(MODISProjection.atScale(scale))

LastFinal_output_CollectionMedian = ee.Image(LastFinal_output_CollectionMedian)

Export.image.toDrive({
  image: LastFinal_output_CollectionMedian,
  folder : 'Marco',
  description: 'LastratioNDVICumMean',
 crs: 'EPSG:4326',
  region: Rectangle1,
  maxPixels: 1e13,
  scale:'5565.974539663679' 
})


*/

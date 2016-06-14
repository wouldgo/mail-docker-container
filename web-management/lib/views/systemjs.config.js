(function inBrowser() {
  'use strict';

  // map tells the System loader where to look for things
  const map = {
      'app': 'app', // 'dist',
      '@angular': '../../node_modules/@angular',
      'angular2-in-memory-web-api': '../../node_modules/angular2-in-memory-web-api',
      'rxjs': '../../node_modules/rxjs'
    }
    // packages tells the System loader how to load when no filename and/or no extension
    , packages = {
      'app': {
        'main': 'main.js',
        'defaultExtension': 'js'
      },
      'rxjs': {
        'defaultExtension': 'js'
      },
      'angular2-in-memory-web-api': {
        'main': 'index.js',
        'defaultExtension': 'js'
      }
    }
    , ngPackageNames = [
      'common',
      'compiler',
      'core',
      'http',
      'platform-browser',
      'platform-browser-dynamic',
      'router',
      'router-deprecated',
      'upgrade'
    ]
      // Individual files (~300 requests):
    , packIndex = pkgName => {
      packages[`@angular/${pkgName}`] = {
        'main': 'index.js',
        'defaultExtension': 'js'
      };
    }
      // Bundled (~40 requests):
    , packUmd = pkgName => {
      packages[`@angular/${pkgName}`] = {
        'main': `${pkgName}.umd.js`,
        'defaultExtension': 'js'
      };
    }
    // Most environments should use UMD; some (Karma) need the individual index files
    , setPackageConfig = System.packageWithIndex ? packIndex : packUmd;

  // Add package entries for angular packages
  ngPackageNames.forEach(setPackageConfig);
  System.config({
    map,
    packages
  });
}());

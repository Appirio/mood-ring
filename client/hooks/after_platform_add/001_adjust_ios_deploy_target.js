#!/usr/bin/env node

var IOS_DEPLOYMENT_TARGET = '7.0';

var fs = require("fs"),
    path = require("path"),
    shell = require("shelljs"),
    xcode = require('xcode'),
    projectRoot = process.argv[2];

function updateDeploymentTarget(xcodeProject, xcodeProjectPath, targetVersion){
  xcodeProject.updateBuildProperty('IPHONEOS_DEPLOYMENT_TARGET', targetVersion);
  fs.writeFileSync(xcodeProjectPath, xcodeProject.writeSync(), 'utf-8');
}

function getProjectName(protoPath) {
    var cordovaConfigPath = path.join(protoPath, 'config.xml');
    var content = fs.readFileSync(cordovaConfigPath, 'utf-8');

    return /<name>([\s\S]*)<\/name>/mi.exec(content)[1].trim();
}

/*
  This is our runner function. It sets up the project paths, 
  parses the project file using xcode and delegates to our updateDeploymentTarget
  that does the actual work.
*/

function run(projectRoot){
  var projectName = getProjectName(projectRoot),
      xcodeProjectName = projectName + '.xcodeproj',
      xcodeProjectPath = path.join(projectRoot, 'platforms', 'ios', xcodeProjectName, 'project.pbxproj'),
      xcodeProject;
  
  if(!fs.existsSync(xcodeProjectPath)) { return; }

  xcodeProject = xcode.project(xcodeProjectPath);

  shell.echo("Adjusting iOS deployment target for " + projectName + " to: [" + IOS_DEPLOYMENT_TARGET + "] ...");

  xcodeProject.parseSync();

  updateDeploymentTarget(xcodeProject, xcodeProjectPath, IOS_DEPLOYMENT_TARGET);
  shell.echo('[' + xcodeProjectPath + '] now has deployment target set as:[' + IOS_DEPLOYMENT_TARGET + '] ...');
}

run(projectRoot);

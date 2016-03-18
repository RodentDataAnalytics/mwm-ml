%Tests for file input

function tests = readFileTests
  tests = functiontests(localfunctions);
end

%Make sure read_ethovision fails when an invalid file is passed to it
function testReadEthovisionBadFile(testCase)
   filename = 'bad_ethovisionfile.csv';
   testCase.verifyError(@()read_ethovision(filename),'read_ethovision:InvalidFileFormat');
end

%Ensure that read_ethovision gives the same cell array as the function it
%replaced -- robustcsvread
function testReadEthovisionGoodFile(testCase)
   filename = 'good_ethovisionfile.csv';
   old_data = robustcsvread(filename);
   new_data = read_ethovision(filename);
   testCase.verifyTrue(isequal(old_data,new_data) );
end
%This is a temporary test to justify the replacement of robustcsvread. This test should eventually
%be replaced by a function that simpliy verifies a correct file read.

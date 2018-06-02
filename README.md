# MetadataPropagation
Scripts and notes about measuring metadata propagation in R&amp;E federations

This is prepping some background data for https://wiki.geant.org/display/gn43tip/New+Idea+Submission#NewIdeaSubmission-EnhanceeduGAINopsinstrumentationwithgeneralmetadatadashboardandaugmentexistingeduGAINAPItoquerysaidstats

Author: Alex Stuart, alex.stuart@jisc.ac.uk

## Process

### Initial deployment

- Deploy a Shibboleth SP on RedHat Enterprise Linux 7
- Register the SP, example using hostname p3w-ds.dev.ukfederation.org.uk

### Prepare a test run

- Obtain a UUID from `cat /proc/sys/kernel/random/uuid`, example is 464bdab4-0b5d-4fca-8543-ae135f8ced01  
- Edit the shibboleth2.xml file, add handlerURL="/464bdab4-0b5d-4fca-8543-ae135f8ced01" as an XML attribute of the Sessions element  
- Restart the SP  
- Ensure the endpoint is in the metadata, from https://p3w-ds.dev.ukfederation.org.uk/464bdab4-0b5d-4fca-8543-ae135f8ced01/Metadata
- Register the endpoint
```
    <md:AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://p3w-ds.dev.ukfederation.org.uk/464bdab4-0b5d-4fca-8543-ae135f8ced01/SAML2/POST" index="7"/>
```

### The test run 

When you set off the test runs depends on whether you want the IdPs which use MDQ to have the SP metadata in cache. If you want them to have the metadata in cache, you should start the test some time (a few minutes) before the new metadata is published. Starting the test after the new metadata has been published should (in most circumstances) ensure that the IdPs using MDQ do not have the probe SP's metadata in cache.

Whichever start time you choose, the command to run is something like:
```
nohup ./propagate.pl -r https://p3w-ds.dev.ukfederation.org.uk/464bdab4-0b5d-4fca-8543-ae135f8ced01/Login -f 2018-04-04-Shib-v3-IdP-entityIDs.txt >> results/2018-06-01-output.txt &
```

The output file contains one line per probe, consisting of datestamp, entityID, HTTP return code triples. When you're finished recording you stop the process using kill.

### Post-processing

- first200.pl determines the first occurence of HTTP 200 success  
- increasing.pl record timestamps when number increases
- process.sh runs both those scripts together and outputs (timestamp, number) pairs into an output file
- plot.R takes the output from process.sh and makes a preview PNG file of results

```
$ ./process.sh results/2018-06-01-output.txt 
$ ./plot.R results/2018-06-01-output.txt.processed 
$ ls -l results/2018-06-01-output.txt.processed.png
-rw-r--r--@ 1 alex.stuart  staff  25421  2 Jun 09:09 results/2018-06-01-output.txt.processed.png
```

## Copyright and License

The contents of this repository are Copyright (C) the named contributors or their
employers, as appropriate.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

> <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.


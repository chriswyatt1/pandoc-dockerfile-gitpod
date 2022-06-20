# Simple RNA-Seq pipeline

To demonstrate a real-world biomedical scenario, we will implement a
proof of concept RNA-Seq pipeline which:

1.  Indexes a transcriptome file

2.  Performs quality controls

3.  Performs quantification

4.  Creates a MultiQC report

This will be done using a series of seven scripts, each of which builds
on the previous to create a complete workflow. You can find these in the
tutorial folder (`script1.nf` - `script7.nf`).

# Define the pipeline parameters

Parameters are inputs and options that can be changed when the pipeline
is run.

The script `script1.nf` defines the pipeline input parameters.

``` nextflow
params.reads = "$projectDir/data/ggal/*_{1,2}.fq"
params.transcriptome_file = "$projectDir/data/ggal/transcriptome.fa"
params.multiqc = "$projectDir/multiqc"

println "reads: $params.reads"
```

Run it by using the following command:

    nextflow run script1.nf

Try to specify a different input parameter in your execution command,
for example:

    nextflow run script1.nf --reads "/workspace/nf-training-public/nf-training/data/ggal/gut_{1,2}.fq"

Modify the `script1.nf` by adding a fourth parameter named `outdir` and
set it to a default path that will be used as the pipeline output
directory.

``` nextflow
params.reads = "$projectDir/data/ggal/*_{1,2}.fq"
params.transcriptome_file = "$projectDir/data/ggal/transcriptome.fa"
params.multiqc = "$projectDir/multiqc"
params.outdir = "results"
```

Modify `script1.nf` to print all of the pipeline parameters by using a
single `log.info` command as a [multiline
string](https://www.nextflow.io/docs/latest/script.html#multi-line-strings)
statement.

<div class="tip">

See an example
[here,window="\_blank"](https://github.com/nextflow-io/rnaseq-nf/blob/3b5b49f/main.nf#L41-L48).

</div>

Add the following to your script file:

``` nextflow
log.info """\
         R N A S E Q - N F   P I P E L I N E
         ===================================
         transcriptome: ${params.transcriptome_file}
         reads        : ${params.reads}
         outdir       : ${params.outdir}
         """
         .stripIndent()
```

In this step you have learned:

1.  How to define parameters in your pipeline script

2.  How to pass parameters by using the command line

3.  The use of `$var` and `${var}` variable placeholders

4.  How to use multiline strings

5.  How to use `log.info` to print information and save it in the log
    execution file

# Create a transcriptome index file

Nextflow allows the execution of any command or script by using a
`process` definition.

A `process` is defined by providing three main declarations: the process
[`inputs`](https://www.nextflow.io/docs/latest/process.html#inputs),
[`outputs`](https://www.nextflow.io/docs/latest/process.html#outputs)
and command
[`script`](https://www.nextflow.io/docs/latest/process.html#script).

To add a transcriptome `index` processing step, try adding the following
code blocks to your `script1.nf`. Alternatively, these code blocks have
already been added to `script2.nf`.

``` nextflow
/*
 * define the `index` process that creates a binary index
 * given the transcriptome file
 */
process index {

    input:
    path transcriptome

    output:
    path 'salmon_index'

    script:
    """
    salmon index --threads $task.cpus -t $transcriptome -i salmon_index
    """
}
```

Additionally, add a workflow scope containing an input channel
definition and the index process:

``` nextflow
workflow {

    in_channel = Channel.from(params.transcriptome_file).collect()

    index_ch = index( in_channel )

}
```

Here, the `transcriptome_file` parameter is defined as `in_channel` and
used as the input for the `index` process. The `index` process (using
the `salmon` tool) creates `salmon_index`, an indexed transcriptome that
is passed as an output to the `index_ch` channel.

<div class="note">

The `input` declaration defines a `transcriptome` path variable which is
used in the `script` as a reference (using the dollar symbol) in the
Salmon command line.

</div>

<div class="important">

Resource requirements such as CPUs and memory limits can change with
different workflow executions and platforms. Nextflow can use $task.cpus
as a variable for the number of CPUs. See process directives
documentation for more
[details](https://www.nextflow.io/docs/latest/process.html#directives).

</div>

Run it by using the command:

    nextflow run script2.nf

The execution will fail because `salmon` is not installed in your
environment.

Add the command line option `-with-docker` to launch the execution
through a Docker container, as shown below:

    nextflow run script2.nf -with-docker

This time the execution will work because it uses the Docker container
`nextflow/rnaseq-nf` that is defined in the `nextflow.config` file in
your current directory. If you are running this script locally then you
will need to download docker to your machine, log in and activate
docker, and allow the script to download the container containing the
run scripts. You can learn more about docker
[here](https://www.nextflow.io/docs/latest/docker.html).

To avoid adding `-with-docker` each time you execute the script, add the
following line to the `nextflow.config` file:

    docker.enabled = true

Enable the Docker execution by default by adding the above setting in
the `nextflow.config` file.

Print the output of the `index_ch` channel by using the
[view](https://www.nextflow.io/docs/latest/operator.html#view) operator.

Add the following to the end of your script file:

``` nextflow
index_ch.view()
```

If you have more CPUs available, try changing your script to request
more resources for this process. For example, see the [directive
docs](https://www.nextflow.io/docs/latest/process.html#cpus).
`$task.cpus` is already specified in this script, so setting the number
of CPUs as a directive will tell Nextflow to run this job.

Add `cpus 2` to the top of the index process:

``` nextflow
process index {
    cpus 2
    input:
    ...
```

Then check it worked by looking at the script executed in the work
directory. Look for the hexidecimal (e.g.
work/7f/f285b80022d9f61e82cd7f90436aa4/), Then `cat` the `.command.sh`
file.

Use the command `tree work` to see how Nextflow organizes the process
work directory. Check
[here](https://www.tecmint.com/linux-tree-command-examples/) if you need
to download `tree`.

It should look something like this:

    work
    ├── 17
    │   └── 263d3517b457de4525513ae5e34ea8
    │       ├── index
    │       │   ├── complete_ref_lens.bin
    │       │   ├── ctable.bin
    │       │   ├── ctg_offsets.bin
    │       │   ├── duplicate_clusters.tsv
    │       │   ├── eqtable.bin
    │       │   ├── info.json
    │       │   ├── mphf.bin
    │       │   ├── pos.bin
    │       │   ├── pre_indexing.log
    │       │   ├── rank.bin
    │       │   ├── refAccumLengths.bin
    │       │   ├── ref_indexing.log
    │       │   ├── reflengths.bin
    │       │   ├── refseq.bin
    │       │   ├── seq.bin
    │       │   └── versionInfo.json
    │       └── transcriptome.fa -> /workspace/Gitpod_test/data/ggal/transcriptome.fa
    ├── 7f

In this step you have learned:

1.  How to define a process executing a custom command

2.  How process inputs are declared

3.  How process outputs are declared

4.  How to print the content of a channel

5.  How to access the number of available CPUs

# Collect read files by pairs

This step shows how to match **read** files into pairs, so they can be
mapped by **Salmon**.

Edit the script `script3.nf` by adding the following statement as the
last line in the workflow scope:

    read_pairs_ch.view()

Save it and execute it with the following command:

    nextflow run script3.nf

It will print something similar to this:

    [gut, [/.../data/ggal/gut_1.fq, /.../data/ggal/gut_2.fq]]

The above example shows how the `read_pairs_ch` channel emits tuples
composed of two elements, where the first is the read pair prefix and
the second is a list representing the actual files.

Try it again specifying different read files by using a glob pattern:

    nextflow run script3.nf --reads 'data/ggal/*_{1,2}.fq'

<div class="important">

File paths that include one or more wildcards ie. `*`, `?`, etc., MUST
be wrapped in single-quoted characters to avoid Bash expanding the glob.

</div>

Use the [set](https://www.nextflow.io/docs/latest/operator.html#set)
operator in place of `=` assignment to define the `read_pairs_ch`
channel.

``` nextflow
Channel
    .fromFilePairs( params.reads )
    .set { read_pairs_ch }
```

Use the `checkIfExists` option for the
[fromFilePairs](https://www.nextflow.io/docs/latest/channel.html#fromfilepairs)
method to check if the specified path contains file pairs.

``` nextflow
Channel
    .fromFilePairs( params.reads, checkIfExists: true )
    .set { read_pairs_ch }
```

In this step you have learned:

1.  How to use `fromFilePairs` to handle read pair files

2.  How to use the `checkIfExists` option to check for the existence of
    input files

3.  How to use the `set` operator to define a new channel variable

# Perform expression quantification

`script4.nf` adds the `quantification` process as a new workflow scope
line.

In this workflow scope, note how the `index_ch` channel, declared as
output in the `index` process, is now used as an input channel for the
`quantification` process.

Also, note how the input is declared in the `quantification` process,
the first being a `path` from the `index_ch` and the second being a
`tuple` composed of two elements (the `sample_id` and the `reads`) in
order to match the structure of the items emitted by the `read_pairs_ch`
channel.

Execute it by using the following command:

    nextflow run script4.nf -resume

You will see the execution of the `quantification` process.

When using the `-resume` option, any step that has already been
processed is skipped.

Try to execute the same script again with more read files, as shown
below:

    nextflow run script4.nf -resume --reads 'data/ggal/*_{1,2}.fq'

You will notice that the `quantification` process is executed multiple
times.

Nextflow parallelizes the execution of your pipeline simply by providing
multiple sets of input data to your script.

<div class="note">

It may be useful to apply optional settings to a specific process using
[directives](https://www.nextflow.io/docs/latest/process.html#directives)
by specifying them in the process body.

</div>

Add a [tag](https://www.nextflow.io/docs/latest/process.html#tag)
directive to the `quantification` process to provide a more readable
execution log.

Add the following before the input declaration: \`\`\` tag "Salmon on
$sample\_id" \`\`\`

Add a
[publishDir](https://www.nextflow.io/docs/latest/process.html#publishdir)
directive to the `quantification` process to store the process results
in a directory of your choice.

Add the following before the ‘input\` declaration in the
`quantification` process: \`\`\` publishDir params.outdir, mode:'copy’
\`\`\`

In this step you have learned:

1.  How to connect two processes together by using the channel
    declarations

2.  How to `resume` the script execution and skip cached steps

3.  How to use the `tag` directive to provide a more readable execution
    output

4.  How to use the `publishDir` directive to store a process results in
    a path of your choice

# Quality control

Next, we implement a FASTQC quality control step for your input reads
(using the label `fastqc`). The inputs are the same as the read pairs
used in the `quantification` step.

You can run it by using the following command:

    nextflow run script5.nf -resume

Nextflow DSL2 knows to split the `reads_pair_ch` into two identical
channels as they are required twice as an input for both of the `fastqc`
and the `quantification` process.

# MultiQC report

This step collects the outputs from the `quantification` and `fastqc`
processes to create a final report using the
[MultiQC](http://multiqc.info/) tool.

Execute the next script with the following command:

    nextflow run script6.nf -resume --reads 'data/ggal/*_{1,2}.fq'

It creates the final report in the `results` folder in the current
`work` directory.

In this script, note the use of the
[mix,window="\_blank"](https://www.nextflow.io/docs/latest/operator.html#mix)
and
[collect,window="\_blank"](https://www.nextflow.io/docs/latest/operator.html#collect)
operators chained together to gather the outputs of the `quantification`
and `fastqc` processes as a single input.
[Operators](https://www.nextflow.io/docs/latest/operator.html) can be
used to combine and transform channels.

    multiqc(quant_ch.mix(fastqc_ch).collect())

We only want one task of MultiQC to be executed to produces one report.
Therefore, we use the `mix` channel operator to combine the two channels
followed by the `collect` operator, to return the complete channel
contents as a single element.

In this step you have learned:

1.  How to collect many outputs to a single input with the `collect`
    operator

2.  How to `mix` two channels into a single channel

3.  How to chain two or more operators together

# Handle completion event

This step shows how to execute an action when the pipeline completes the
execution.

Note that Nextflow processes define the execution of **asynchronous**
tasks i.e., they are not executed one after another as if they were
written in the pipeline script in a common **imperative** programming
language.

The script uses the `workflow.onComplete` event handler to print a
confirmation message when the script completes.

Try to run it by using the following command:

    nextflow run script7.nf -resume --reads 'data/ggal/*_{1,2}.fq'

# Email notifications

Send a notification email when the workflow execution completes using
the `-N <email address>` command-line option.

Note: this requires the configuration of a SMTP server in the nextflow
config file. Below is an example `nextflow.config` file showing the
settings you would have to configure:

``` config
mail {
  from = 'info@nextflow.io'
  smtp.host = 'email-smtp.eu-west-1.amazonaws.com'
  smtp.port = 587
  smtp.user = "xxxxx"
  smtp.password = "yyyyy"
  smtp.auth = true
  smtp.starttls.enable = true
  smtp.starttls.required = true
}
```

See [mail
documentation,window="\_blank"](https://www.nextflow.io/docs/latest/mail.html#mail-configuration)
for details.

# Custom scripts

Real-world pipelines use a lot of custom user scripts (BASH, R, Python,
etc.) Nextflow allows you to consistently use and manage these scripts.
Simply put them in a directory named `bin` in the pipeline project root.
They will be automatically added to the pipeline execution `PATH`.

For example, create a file named `fastqc.sh` with the following content:

``` bash
#!/bin/bash
set -e
set -u

sample_id=${1}
reads=${2}

mkdir fastqc_${sample_id}_logs
fastqc -o fastqc_${sample_id}_logs -f fastq -q ${reads}
```

Save it, give execute permission, and move it into the `bin` directory
as shown below:

``` bash
chmod +x fastqc.sh
mkdir -p bin
mv fastqc.sh bin
```

Then, open the ‘script7.nf\` file and replace the `fastqc` process’
script with the following code:

``` nextflow
  script:
  """
  fastqc.sh "$sample_id" "$reads"
  """
```

Run it as before:

    nextflow run script7.nf -resume --reads 'data/ggal/*_{1,2}.fq'

In this step you have learned:

1.  How to write or use existing custom scripts in your Nextflow
    pipeline.

2.  How to avoid the use of absolute paths by having your scripts in the
    `bin/` folder.

# Metrics and reports

Nextflow can produce multiple reports and charts providing several
runtime metrics and execution information.

Run the
[rnaseq-nf,window="\_blank"](https://github.com/nextflow-io/rnaseq-nf)
pipeline previously introduced as shown below:

    nextflow run rnaseq-nf -with-docker -with-report -with-trace -with-timeline -with-dag dag.png

The `-with-docker` option launches each task of the execution as a
Docker container run command.

The `-with-report` option enables the creation of the workflow execution
report. Open the file `report.html` with a browser to see the report
created with the above command.

The `-with-trace` option enables the creation of a tab separated file
containing runtime information for each executed task. Check the
`trace.txt` for an example.

The `-with-timeline` option enables the creation of the workflow
timeline report showing how processes were executed over time. This may
be useful to identify the most time consuming tasks and bottlenecks. See
an example at [this
link,window="\_blank"](https://www.nextflow.io/docs/latest/tracing.html#timeline-report).

Finally, the `-with-dag` option enables the rendering of the workflow
execution direct acyclic graph representation. Note: This feature
requires the installation of
[Graphviz,window="\_blank"](http://www.graphviz.org/) on your computer.
See
[here,window="\_blank"](https://www.nextflow.io/docs/latest/tracing.html#dag-visualisation)
for further details. Then try running :

dot -Tpng dag.dot \> graph.png open graph.png\</programlisting\>

Note: runtime metrics may be incomplete for run short running tasks as
in the case of this tutorial.

<div class="note">

You view the HTML files by right-clicking on the file name in the left
side-bar and choosing the **Preview** menu item.

</div>

# Run a project from GitHub

Nextflow allows the execution of a pipeline project directly from a
GitHub repository (or similar services, e.g., BitBucket and GitLab).

This simplifies the sharing and deployment of complex projects and
tracking changes in a consistent manner.

The following GitHub repository hosts a complete version of the workflow
introduced in this tutorial:

<https://github.com/nextflow-io/rnaseq-nf>

You can run it by specifying the project name and launching each task of
the execution as a Docker container run command:

    nextflow run nextflow-io/rnaseq-nf -with-docker

It automatically downloads the container and stores it in the
`$HOME/.nextflow` folder.

Use the command `info` to show the project information:

    nextflow info nextflow-io/rnaseq-nf

Nextflow allows the execution of a specific revision of your project by
using the `-r` command line option. For example:

    nextflow run nextflow-io/rnaseq-nf -r dev

Revision are defined by using Git tags or branches defined in the
project repository.

Tags enable precise control of the changes in your project files and
dependencies over time.

# More resources

  - [Nextflow documentation,window="\_blank"](http://docs.nextflow.io) -
    The Nextflow docs home.

  - [Nextflow
    patterns,window="\_blank"](https://github.com/nextflow-io/patterns)
    - A collection of Nextflow implementation patterns.

  - [CalliNGS-NF,window="\_blank"](https://github.com/CRG-CNAG/CalliNGS-NF)
    - A Variant calling pipeline implementing GATK best practices.

  - [nf-core,window="\_blank"](http://nf-co.re/) - A community
    collection of production ready genomic pipelines.

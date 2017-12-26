# Processador de Pedido

## Install
[Oracle SOA Suite 12.2.1 QuickStart Download](http://www.oracle.com/technetwork/middleware/soasuite/downloads/soasuite1221-quickstartdownload-3050431.html)

#### Set $ORACLE_HOME:

Linux mint:

```bash
sudo xed ~/.bashrc
```
add:
```
export ORACLE_HOME=$HOME/Oracle/Oracle12c/osb
```

#### Create domain:


```bash
cd $ORACLE_HOME/oracle_common/common/bin

export QS_TEMPLATES="$ORACLE_HOME/soa/common/templates/wls/oracle.soa_template.jar, $ORACLE_HOME/osb/common/templates/wls/oracle.osb_template.jar"

./qs_config.sh

```

Adicionar o servidor como `JBpelStandaloneWebLogicServer` no ApplicationServers do JDEV

#### Criar MSDs
**localGtwDefinitions:**

> Resources > New SOA-MDS Connection > File Based MDS > MDS Root Folder: **%PATH%/GTW_DEFINITIONS**

**oramds:**

> Resources > New SOA-MDS Connection > File Based MDS > MDS Root Folder: **$ORACLE_NOME/user_projects/domains/base_domain/store/gmds/mds-soa/soa-infra**


## Tune your JDeveloper 12c

**Step 1:** Configure JVM settings in jdev.conf

    Path: $MV_HOME$/jdeveloper/jdev/bin/jdev.conf

```
# optimize the JVM for strings / text editing
AddVMOption -XX:+UseStringCache
AddVMOption -XX:+OptimizeStringConcat
AddVMOption -XX:+UseCompressedStrings

# if on a 64-bit system, but using less than 32 GB RAM, this reduces object pointer memory size
AddVMOption -XX:+UseCompressedOops

# use an aggressive garbage collector (constant small collections)
AddVMOption -XX:+AggressiveOpts

# for multi-core machines, use multiple threads to create objects and reduce pause times
AddVMOption -XX:+UseConcMarkSweepGC
AddVMOption -DVFS_ENABLE=true
AddVMOption -Dsun.java2d.ddoffscreen=false
AddVMOption -XX:+UseParNewGC
AddVMOption -XX:+CMSIncrementalMode
AddVMOption -XX:+CMSIncrementalPacing
AddVMOption -XX:CMSIncrementalDutyCycleMin=0
AddVMOption -XX:CMSIncrementalDutyCycle=10
```

**Step 2:** Configure Jdeveloper memory settings in ide.conf

    Path: $MV_HOME$/jdeveloper/ide/bin/ide.conf

```
# Set the default memory options for the Java VM which apply to both 32 and 64-bit VM's.
# These values can be overridden in the user .conf file, see the comment at the top of this file.

AddVMOption -Xms2048M
AddVMOption -Xmx4096M
```

**Step 3:** Maybe Disable "Build After Save"



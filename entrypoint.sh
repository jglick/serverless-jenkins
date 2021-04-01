mkdir -p /var/jenkins_home/jobs/p
cat > /var/jenkins_home/jobs/p/config.xml <<EOF
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition>
  <description></description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition">
    <scm class="hudson.plugins.git.GitSCM">
      <configVersion>2</configVersion>
      <userRemoteConfigs>
        <hudson.plugins.git.UserRemoteConfig>
          <url>$GITHUB_WORKSPACE</url>
        </hudson.plugins.git.UserRemoteConfig>
      </userRemoteConfigs>
      <branches>
        <hudson.plugins.git.BranchSpec>
          <name>$GITHUB_SHA</name>
        </hudson.plugins.git.BranchSpec>
      </branches>
      <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
      <submoduleCfg class="empty-list"/>
      <extensions/>
    </scm>
    <scriptPath>Jenkinsfile</scriptPath>
    <lightweight>false</lightweight>
  </definition>
  <triggers/>
  <quietPeriod>0</quietPeriod>
  <disabled>false</disabled>
</flow-definition>
EOF
bash /usr/local/bin/jenkins.sh &
while :
do
    sleep 1
    curl -f -s -o /tmp/cli.jar http://localhost:8080/jnlpJars/jenkins-cli.jar && break
done
if java -jar /tmp/cli.jar -s http://localhost:8080/ build p -f -v
then
    result=success
    title='Jenkins build passed 🌞'
else
    result=failure
    title='Jenkins build failed ⛈️'
fi
echo result=$result
chromium --headless --no-sandbox --window-size=1280,1024 --screenshot=/tmp/screenshot.png http://localhost:8080/job/p/1/flowGraphTable/
cd $GITHUB_WORKSPACE
git clean -fdx
branch=bin-$RANDOM
git checkout --orphan $branch
git reset --hard
mv /tmp/screenshot.png .
git add screenshot.png
git config --global user.email xxx@xxx.net
git config --global user.name xxx
git commit -m screenshot
git push origin $branch
uploaded=https://raw.githubusercontent.com/$GITHUB_REPOSITORY/$branch/screenshot.png
curl \
    --header "Authorization: Bearer $GITHUB_TOKEN" \
    -d '{"name":"Jenkins","head_sha":"'$GITHUB_SHA'","conclusion":"'$result'","output":{"title":"'"$title"'","summary":"","images":[{"alt":"screenshot","image_url":"'$uploaded'"}]}}' \
    $GITHUB_API_URL/repos/$GITHUB_REPOSITORY/check-runs

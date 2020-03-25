def on_duffy_node(String script)
{
	sh 'ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -l root ${DUFFY_NODE}.ci.centos.org "' + script + '"'
}

node('cico-workspace')
{
	stage('Checkout')
	{
		checkout scm
	}
	stage('Get commit message')
	{
		env.commit_message = sh(
			script: "echo 'Upstream commit:' `git log -1 --pretty=%B`",
			returnStdout: true
		)
	}
	stage('Allocate Duffy node')
	{
		// Get a duffy node and set the DUFFY_NODE and SSID environment variables.
		duffy_rtn = sh(
			script: 'cico --debug node get -f value -c hostname -c comment --retry-count 16 --retry-interval 60',
			returnStdout: true
		).trim().tokenize(' ')
		env.DUFFY_NODE = duffy_rtn[0]
		env.SSID = duffy_rtn[1]
	}
	try
	{
		stage('Send files')
		{
			on_duffy_node("mkdir -p /root/build")
			withCredentials(bindings: [
				sshUserPrivateKey(
					credentialsId: 'java_packaging_howto_deploy_key_id',
					keyFileVariable: 'SSH_FILE',
					passphraseVariable: '',
					usernameVariable: '')])
			{
				sh("scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no '${SSH_FILE}' 'root@${DUFFY_NODE}.ci.centos.org:/root/build/jenkins.private'")
			}
			sh("scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no 'docker-build.sh' 'root@${DUFFY_NODE}.ci.centos.org:/root/build/'")
		}
		stage('Build')
		{
			on_duffy_node("sudo yum -y install podman")
			on_duffy_node("podman run --privileged -e COMMIT_MESSAGE=\\\"${commit_message}\\\" -v /root/build:/mnt/build -it fedora:rawhide /mnt/build/docker-build.sh")
		}
	}
	finally
	{
		stage('Deallocate node')
		{
			sh 'cico node done ${SSID}'
		}
	}
}

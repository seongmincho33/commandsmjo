alias jv='jenv versions'
alias js='jenv local'
alias jg='jenv global'

# Java Compile & Run
alias jc='javac'
function jarun() {
    if [ -f "$1" ]; then
        javac "$1" && java "${1%.*}"
    else
        echo "❌ 파일을 찾을 수 없어요: $1"
    fi
}

# Gradle Shortcuts
alias grb='./gradlew clean build'
alias grr='./gradlew bootRun'

# Maven Shortcuts
alias mvb='mvn clean install'
alias mvr='mvn spring-boot:run'
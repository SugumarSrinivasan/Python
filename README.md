# Python CI/CD Pipeline with Jenkins

This project implements a Jenkins CI/CD pipeline for a Python application. It includes steps for building, testing, linting, packaging, publishing to GitHub Releases, and deploying with manual approval.

## 📁 Project Structure

<img width="1395" alt="image" src="https://github.com/user-attachments/assets/37af8843-376d-4107-a01a-de63907fa4da" />

## 🔧 Jenkins Pipeline Stages

### 1. **Checkout**
- Clones the main branch from the GitHub repository.

### 2. **Build**
- Sets up a Python virtual environment.
- Installs dependencies from `requirements.txt`.

### 3. **Test**
- Runs unit tests using `pytest`.
- Generates a code coverage report in HTML format.

### 4. **Scan**
- Performs code linting using `pylint` on the `app` and `tests` directories.

### 5. **Package**
- Packages the app, tests, and required files into a ZIP archive.
- Archives the artifact (`dist/app.zip`) in Jenkins.

### 6. **Publish**
- Creates a new release on GitHub.
- Uploads the ZIP package as a release asset.

### 7. **DEVDeploy**
- Requires manual approval via Jenkins input step.
- Downloads the latest release from GitHub.
- Extracts and runs the application after setting up a new virtual environment.

## 🛠️ Prerequisites

- **Jenkins Plugins:**
  - Git
  - Pipeline
  - HTML Publisher
  - Credentials Binding

- **GitHub Personal Access Token:**
  - Store it in Jenkins Credentials as a "Secret text" with ID: `GITHUB_TOKEN`

- **Python 3.x** must be installed on the Jenkins agent.

## 🚀 Deployment

Once the build and release are successful:
1. Jenkins will prompt for deployment approval.
2. Upon approval, the latest release artifact will be downloaded and run in the `DEV` environment.

## 📊 Code Coverage

Code coverage reports are generated in the `project/htmlcov` directory and published to Jenkins as an HTML report.

## 🧹 Post Build

Regardless of build result:
- Code coverage reports are archived.
- Workspace is cleaned up.

## 📄 License

This project is licensed under the MIT License.

## ✍️ Author

Sugumar Srinivasan  
[GitHub](https://github.com/SugumarSrinivasan)

#!/bin/bash
set -e

# Helpers
ask_for_sudo() {
    # Ask for the administrator password upfront
    sudo -v
    # Update existing `sudo` time stamp until this script has finished
    # https://gist.github.com/cowboy/3118588
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done &> /dev/null &
}

print_info() {
    # Print output in purple
    printf "\n\e[0;35m $1\e[0m\n\n"
}

print_question() {
    # Print output in yellow
    printf "\e[0;33m  [?] $1\e[0m"
}

print_success() {
    # Print output in green
    printf "\n\e[0;32m  [✔] $1\e[0m\n\n"
}

# Main function
main () {

  print_info "Install/Update script"
  print_question "Please provide credentials > "
  ask_for_sudo

  # Homebrew
  if ! type "brew" > /dev/null; then
    print_info "\nSTEP 1/9 : Homebrew install"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    print_success "Homebrew successfuly installed"
  else
    print_info "STEP 1/9 : Homebrew update"
    brew update && brew upgrade && brew outdated && brew cleanup -s
    print_success "Homebrew successfuly updated"
  fi


  # Base
  print_info "STEP 2/9 : Basic software install/update"
  brew bundle --file=Brewfile-base
  print_success "Basic software install completed"

  # ZSH
  print_info "STEP 3/9 : zsh install"
  if ! type "/usr/local/bin/zsh" > /dev/null; then
    brew install zsh zsh-completions
    echo "/usr/local/bin/zsh" | sudo tee -a /etc/shells && chsh -s /usr/local/bin/zsh
    print_success "zsh install completed"
  else
      print_success "zsh already installed"
  fi
  ## Prezto Powerlevel9k theme Vundle and Plugins
  print_info "STEP 4/9 : zsh plugin and symlink creation"
  zsh ./post-install-zsh
  print_success "zsh plugin and symlink creation completed"

  # Apps
  print_info "STEP 5/9 : Apps install"
  brew bundle --file=Brewfile-apps
  print_success "Apps install completed"
  ## Apps and Atom plugins
  print_info "STEP 6/9 : Apps and plugin install"
  source ./post-install-apps
  print_success "Apps and plugin install completed"

  # Fonts
  print_info "STEP 7/9 : Fonts install"
  brew bundle --file=Brewfile-fonts
  print_success "Fonts install completed"

  # OSX tweaks
  print_info "STEP 8/9 : OSX tweaks install"
  brew bundle --file=Brewfile-osx
  print_success "OSX tweaks install completed"
  ## Customize finder / dock
  print_info "STEP 9/9 : final customization"
  source ./post-install-osx
  print_success "final customization completed"
}

main

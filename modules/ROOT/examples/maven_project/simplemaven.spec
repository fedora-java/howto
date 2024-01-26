Name:           simplemaven
Version:        1.0
Release:        1%{?dist}
Summary:        Simple Maven project
License:        BSD
URL:            https://www.example.com
Source0:        https://www.example.com/simplemaven-1.0.tar.gz
BuildArch:      noarch

BuildRequires:  maven-local

%description
This is simple Maven project.

%package        javadoc
Summary:        Javadoc for %{name}

%description javadoc
This package contains the API documentation for %{name}.

%prep
%setup -q

%build
%mvn_build

%install
%mvn_install

%files -f .mfiles
%files javadoc -f .mfiles-javadoc

%changelog
* Mon Oct 14 2013 Michal Srb <msrb@redhat.com> - 1.0-1
- Initial packaging

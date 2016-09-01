Name:           java-packaging-howto
Version:        5.0.0
Release:        0.git.%(date +%%Y%%m%%d.%%H%%M%%S)
Summary:        Fedora Java packaging HowTo
License:        BSD
URL:            https://github.com/fedora-java/howto
BuildArch:      noarch

Source0:        https://github.com/fedora-java/howto/archive/howto-%{version}.tar.gz

BuildRequires:  make
BuildRequires:  asciidoc
BuildRequires:  dia

Provides:       javapackages-tools-doc = %{version}-%{release}
Obsoletes:      javapackages-tools-doc <= 4.7.0-7

%description
Offline version of Fedora Java packaging HowTo.

%prep
%setup -q

%build
VERSION=Latest make

%install

%files
%license LICENSE
%doc index.html images/xmvn.svg

%changelog

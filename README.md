# 🛰 osculating2mean

to do:
- gitignove asm, figures, ds stroes

## 🎯 Features
- Convert **osculating orbital elements** to/from **mean orbital elements** using spherical harmonics Earth gravity potential in MATLAB.

***
## 🚀 Index

- [Description](#-description)
- [Authors](#-authors)
- [Contact](#-contact)
- [Installation](#-installation)
- [Documentation](#-documentation)
- [Contributing to SAFFRON](#-contributing-to-saffron)
- [Lincense](#-license)
- [References](#-references)

***

## 💡 Description

The **osculating2mean** toolbox is developed for **MATLAB**. The backbone computations of the spherical harmonics Earth gravity potential perturbations are written in FORTRAN and called from MATLAB. 

The [EGM96 NASA GSFC and NIMA Joint Geopotential Model](https://cddis.nasa.gov/926/egm96/) is used.

This package was developed for **non-singular** orbital elements, for **near-circular** orbits, but it may be expanded to general orbits easily. 

***

## ✍🏼 Authors 
Leonardo Pedroso<sup>1</sup> <a href="https://scholar.google.com/citations?user=W7_Gq-0AAAAJ"><img src="https://cdn.icon-icons.com/icons2/2108/PNG/512/google_scholar_icon_130918.png" style="width:1em;margin-right:.5em;"></a> <a href="https://orcid.org/0000-0002-1508-496X"><img src="https://orcid.org/sites/default/files/images/orcid_16x16.png" style="width:1em;margin-right:.5em;" alt="ORCID iD icon"></a> <a href="https://github.com/leonardopedroso"><img src="https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png" style="width:1em;margin-right:.5em;" alt="ORCID iD icon"></a><br>
Pedro Batista<sup>1</sup> <a href="https://scholar.google.com/citations?user=6eon48IAAAAJ"><img src="https://cdn.icon-icons.com/icons2/2108/PNG/512/google_scholar_icon_130918.png" style="width:1em;margin-right:.5em;"></a> <a href="https://orcid.org/0000-0001-6079-0436"><img src="https://orcid.org/sites/default/files/images/orcid_16x16.png" style="width:1em;margin-right:.5em;" alt="ORCID iD icon"></a><br>
<sub>*<sup>1</sup>Institute for Systems and Robotics, Instituto Superior Técnico, Universidade de Lisboa, Portugal<br>
 
***

## 📞 Contact
**osculating2mean** toolbox is currently maintained by Leonardo Pedroso (<a href="mailto:leonardo.pedroso@tecnico.ulisboa.pt">leonardo.pedroso@tecnico.ulisboa.pt</a>).

***
  
## 💿 Installation
  
To install **osculating2mean**:
  
- **Clone** or **download** the repository to the desired installation directory;
- Open the **osculating2mean** installation directory in MATLAB instance and run
  ```m
  make_osculating2mean
  ```
- Add **osculating2mean** to the MATLAB path
   ```m
  addpath('[installation directory]/osculating2mean');
  ```
  
Important notes:
  - The command ```make_osculating2mean``` must be run in the installation directory. If it is run (either when intalling **osculating2mean** or later) in other directory, the EGM96 model data will not be available.
  - Ignore the massive dump of warnings when running ```make_osculating2mean``` :)
  
***  

## 📖 Documentation
The documentation is divided into the following categories:
- [Model synthesis](#model-synthesis)
- [Utilities](#utilities)
  * [Network properties](#network-properties)
  * [Performance metrics](#performance-metrics)
  * [Quadratic continuous knapsack solver](#quadratic-continuous-knapsack-solver)
- [Simulation script](#simulation-script)
- [Chania urban road network](#chania-urban-road-network)
- [Example](#example)

### Model synthesis


***
  
## Example


  
***
  
## ✨ Contributing to **osculating2mean**

The community is encouraged to contribute with 
- Suggestions
- Addition of tools

To contribute to **osculating2mean** 

- Open an issue ([tutorial on how to create an issue](https://docs.github.com/en/issues/tracking-your-work-with-issues/creating-an-issue))
- Make a pull request ([tutorial on how to contribute to GitHub projects](https://docs.github.com/en/get-started/quickstart/contributing-to-projects))
- Or, if you are not familiar with GitHub, [contact the authors](#-contact) 

***

## 📄 License
[MIT License](https://github.com/decenter2021/SAFFRON/blob/master/LICENSE)

***

## 💥 References 
<p align="justify">
<a href="https://elib.dlr.de/103814/1/Spiridonova_ISSFD_2014_upd.pdf">Spiridonova, S., Kirschner, M. and Hugentobler, U., 2014. Precise mean orbital elements determination for LEO monitoring and maintenance.</a>
  
M.C. Eckstein, H. Hechler, A reliable derivation of the perturbations due to any zonal and tesseral harmonics of the geopotential for nearly-circular satellite orbits, ESOC, ESRO SR-13 (1970).
 
Kaula, W.M., 2013. Theory of satellite geodesy: applications of satellites to geodesy. Courier Corporation.
  
<a href="https://doi.org/10.1016/S0098-3004(01)00053-X">Hwang, C. and Hwang, L.S., 2002. Satellite orbit error due to geopotential model error using perturbation theory: applications to ROCSAT-2 and COSMIC missions. Computers & geosciences, 28(3), pp.357-367.</a>

</p> 

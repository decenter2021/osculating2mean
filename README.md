# 🛰 osculating2mean

## 🎯 Features
- Convert **osculating orbital elements** to/from **mean orbital elements** using spherical harmonics Earth gravity potential in MATLAB.

***
## 🚀 Index

- [Description](#-description)
- [Authors](#-authors)
- [Contact](#-contact)
- [Installation](#-installation)
- [Documentation](#-documentation)
- [Example](#-example)
- [Contributing to osculating2mean](#-contributing-to-osculating2mean)
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
- [Osculating elements from/to position-vector](#osculating-elements-fromto-position-vector)
- [Eckstein-Ustinov J2 Perturbations](#eckstein-ustinov-j2-perturbations)
- [Kaula Spherical Harmonics Geopotential Perturbations](#kaula-spherical-harmonics-geopotential-perturbations)

### Osculating elements from/to position-vector

To compute the **osculating orbital elements** from a **position-velocity** vector use
```
OE = rv2OEOsc(x)
```
and to compute the **position-velocity** vector from **osculating orbital elements** use 
```
x = OEOsc2rv(OE)
```
where ```x``` is a $6\times 1$ **position-velocity** vector in **SI units** and ``OE`` is a $6\times 1$ vector of **non-singular orbital elements**, for near-circular orbits, *i.e.*, 
 - $a$: semi-major axis [m]
 - $u$: $\omega + M$ ($\omega$: argument of perigee; $M$: mean anomaly) [rad]
 - $e_x$: $e\cos(\omega)$ ($e$: excentricity)
 - $e_y$: $e\sin(\omega)$
 - $i$: inclination [rad]
 - $\Omega$: longitude of ascending node [rad]
 
 Implementation of these functions was adapted from [(Vallado, 1997)](#-references).
 
To adjust the maximum number of iterations and convergence criteria of the numerical solution of the Kepler equation in ```OEOsc2rv```, it is also possible to set additional arguments 
```
x = OEOsc2rv(OE, MaxIt, epsl)
```
For more details, see the thorough comments in the source code of this function.
 
 
>Example: *compute the osculating orbital elements from/to a position-velocity vector*
>```
>>> x = 1.0e+06 * ...
>   [6.4329;
>   -1.5777;
>   -2.0041;
>    0.0028;
>    0.0042;
>    0.0056];
>>> OE = rv2OEOsc(x);
>>> OE(1)
>ans =
>   6.9195e+06
>>> OE(2:6)
>ans =
>    5.9111
>   -0.0003
>   -0.0004
>    0.9249
>    6.2728
>>> x = OEOsc2rv(OE)
>x =
>   1.0e+06 *
> 
>    6.4329
>   -1.5777
>   -2.0041
>    0.0028
>    0.0042
>    0.0056

***
 
### Eckstein-Ustinov J2 Perturbations

To compute the Eckstein-Ustinov first order perturbations due to $J_2$ use 
```
EUPerturbations =  EcksteinUstinovPerturbations(OEMean)
```
where ```OEMean``` are the non-singular mean orbital elements for which the perturbation is computed and ```EUPerturbations``` are the perturbations to the mean orbital elements. This function is implemented according to [(Eckstein and Hechler, 1970)](#-references).

To convert from **mean orbital elements** to **osculating orbital elements** (or, equivalently, position-velocity) taking into account the **Eckstein-Ustinov** $J_2$ perturbations use 
```
OEOsc = OEMeanEU2OEOsc(OEMean)
```
and to iteratively convert from **osculating orbital elements** (or, equivalently, position-velocity) to **mean orbital elements**, taking into account the **Eckstein-Ustinov** $J_2$ perturbations use 
```
OEMean = OEOsc2OEMeanEU(OEOsc)
```
where ```OEOsc``` is a $6\times 1$ vector of **non-singular osculating orbital elements** for near-circular orbits and ``OEMean`` is a $6\times 1$ vector of **non-singular mean orbital elements** for near-circular orbits, both in **SI units**.
 
To adjust the maximum number of iterations and convergence criteria, it is also possible to set additional arguments 
```
OEMean = OEOsc2OEMeanEU(OEOsc, MaxIt, epslPos, epslVel)
```
For more details, see the thorough comments in the source code of this function.
 
>Example: *compute the mean orbital elements taking into account the Eckstein-Ustinov J2 perturbations*
>```
>>> x = 1.0e+06 * ...
>   [6.4329;
>   -1.5777;
>   -2.0041;
>    0.0028;
>    0.0042;
>    0.0056];
>>> OEOsc = rv2OEOsc(x);
>>> OEMean = OEOsc2OEMeanEU(OEOsc);
>>> OEMean(1)
>ans =
>   6.9150e+06
>>> OEMean(2:6)
>ans =
>    5.9114
>   -0.0007
>   -0.0000
>    0.9247
>    6.2730
>>> OEOsc = OEMeanEU2OEOsc(OEMean);
>>> OEOsc(1)
>ans =
>   6.9195e+06
>>> OEMean(2:6)
>ans =
>    5.9111
>   -0.0003
>   -0.0004
>    0.9249
>    6.2728
 
***
 
### Kaula Spherical Harmonics Geopotential Perturbations

To compute the spherical harmonics geopotential perturbations to the mean orbital elements according to [(Kaula, 2013)](#-references) use 
```
dOE = KaulaGeopotentialPerturbations(t_tdb,OEmean,degree)
```
where ```t_tdb``` is the dynamic baricentric time since J200 in seconds, ```OEMean``` are the non-singular mean orbital elements for which the perturbation is computed, ```degree``` is the maximum degree of the spherical harmonics geopotential model, and ```dOE``` are the perturbations to the following ordered set of orbital elements:
 - $a$ (semi-major axis) [m]
 - $e$ (excentricity)
 - $i$ (inclination) [rad]
 - $\Omega$ (longitude of ascending node) [rad]
 - $\omega$ (argument of perigee) [rad]
 - $M$ (mean anomaly) [rad]
 
The [EGM96 NASA GSFC and NIMA Joint Geopotential Model](https://cddis.nasa.gov/926/egm96/) is used.

The backbone of this function is implemented in FORTRAN, whose source code is based on the programs published in [(Hwang and Hwang, 2002)](#-references). The FORTRAN code is called from MATLAB using a MEX function. 

To convert from *mean orbital elements* to osculating orbital elements (or, equivalently, position-velocity ) taking into account the **spherical harmonics geopotential** perturbations use
```
OEOsc = OEMeanEUK2OEOsc(t_tdb,OEMean,degree) 
```
and to convert from position-velocity (or, equivalently, osculating orbital elements) to mean orbital elements, taking into account the spherical harmonics geopotential perturbations use 
```
OEMean = OEOsc2OEMeanEUK(t_tdb,x,degree) 
```
where the arguments ```t_tdb```and ```degree``` are the same as those of function ```KaulaGeopotentialPerturbations```, ```OEOsc``` is a $6\times 1$ vector of **non-singular osculating orbital elements** for near-circular orbits and ``OEMean`` is a $6\times 1$ vector of **non-singular mean orbital elements** for near-circular orbits, both in **SI units**.
 
The conversion from osculating to mean orbital elements is performed in 3 steps as proposed in [(Spiridonova, Kirschner and Hugentobler, 2014)](#-references):
- Iteratively compute the mean orbital elements taking into account the Eckstein-Ustinov J2 perturbations
- Compute the Kaula geopotential perturbations corresponding to the Eckstein-Ustinov mean orbital elements 
- Compute the mean orbital elements by subtracting the perturbations to the osculating orbital elements
 
>Example: *compute the mean orbital elements taking into account the Kaula Spherical Harmonics Geopotential Perturbations*
>```
>>> x = 1.0e+06 * ...
>   [6.4329;
>   -1.5777;
>   -2.0041;
>    0.0028;
>    0.0042;
>    0.0056];
>>> OEOsc = rv2OEOsc(x);
>>> OEMean = OEOsc2OEMeanEUK(11100,OEOsc,10);
>>> OEMean(1)
>ans =
>   6.9150e+06
>>> OEMean(2:6)
>ans =
>    5.9114
>   -0.0007
>   -0.0000
>    0.9247
>    6.2730
>>> OEOsc = OEMeanEUK2OEOsc(11100,OEMean,10);
>>> OEOsc(1)
>ans =
>   6.9195e+06
>>> OEMean(2:6)
>ans =
>    5.9111
>   -0.0003
>   -0.0004
>    0.9249
>    6.2728
 
*** 
 
## 🦆 Example
 
In this example, which can be run with
 ``` 
 example_osculating2mean
 ``` 
the osculating, mean Eckstein-Ustinov, and mean Eckstein-Ustinov-Kaula orbital elements are compared for a time-series of roughly 10 orbits of a satellite in LEO. The time-series were obtain with a simulation in [TUDAT](https://tudat-space.readthedocs.io/en/latest/) considering:
 - atmospheric drag
 - cannon ball solar radiation pressure
 - third body perturbations from the Sun, Moon, Mars, Venus
 - spherical harmonic gravity up to degree and order 12

 The evolution of the non-singular orbital elements is depicted below
 
![a](https://user-images.githubusercontent.com/40807922/175348654-3d31489a-40ec-4225-b26b-adb244f2e5b7.svg)
![a_zoom](https://user-images.githubusercontent.com/40807922/175348655-1852bd1c-870b-47f0-9910-1024b93a97e8.svg)
![u](https://user-images.githubusercontent.com/40807922/175348627-1d4106da-7657-4221-8cfa-57cb0db738ea.svg) 
![ex](https://user-images.githubusercontent.com/40807922/175348652-9b09ac61-fbea-4422-b6b2-b8120e99be7b.svg)
![ey](https://user-images.githubusercontent.com/40807922/175348649-fbc9ab18-e36a-4b48-9421-37b609817601.svg)
![i](https://user-images.githubusercontent.com/40807922/175348646-940e4843-0022-4239-926b-68bfd851d1b4.svg)
![Omega](https://user-images.githubusercontent.com/40807922/175348644-377a2ff5-2bb7-48ed-9ec4-59ae0630f47f.svg)

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
[MIT License](https://github.com/decenter2021/osculating2mean/blob/master/LICENSE)

***

## 💥 References 
<p align="justify">

  
Eckstein, M.C., Hechler, H., 1970. A reliable derivation of the perturbations due to any zonal and tesseral harmonics of the geopotential for nearly-circular satellite orbits, ESOC, ESRO SR-13.
  
<a href="https://doi.org/10.1016/S0098-3004(01)00053-X">Hwang, C. and Hwang, L.S., 2002. Satellite orbit error due to geopotential model error using perturbation theory: applications to ROCSAT-2 and COSMIC missions. Computers & geosciences, 28(3), pp.357-367.</a>
 
Kaula, W.M., 2013. Theory of satellite geodesy: applications of satellites to geodesy. Courier Corporation.

<a href="https://elib.dlr.de/103814/1/Spiridonova_ISSFD_2014_upd.pdf">Spiridonova, S., Kirschner, M. and Hugentobler, U., 2014. Precise mean orbital elements determination for LEO monitoring and maintenance.</a>

Vallado, D.A., 1997. Fundamentals of astrodynamics and applications. McGraw-Hill.
 

</p> 

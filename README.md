# Model and figure code for "Modeling driver control behavior in both routine and near-accident driving"

This repository provides the MATLAB code used for generating Figs 2, 3, and 5 of:

> Markkula, G. (2014). Modeling driver control behavior in both routine and near-accident driving. Proceedings of the Human Factors and Ergonomics Society Annual Meeting, 58(1), 879–883. [https://doi.org/10.1177/1541931214581185](https://doi.org/10.1177/1541931214581185)


## Pointers

The `do_[...].m` scripts in each subfolder generates one figure or part of a figure. 

The model-fitting code used to generate the parameter values used for the simulations in Figs 2 and 3 seems to be lost in time and is therefore not included here; if you need to fit a looming accumulator model [this repository](https://doi.org/10.17605/OSF.IO/647SY) might be useful. 

The code generating Fig 5 includes a working implementation of the intermittent braking control model based on looming accumulation that is described in the paper. This implementation is very similar to what has later been described in more detail in:

> Svärd, M., Markkula, G., Engström, J., Granum, F., & Bärgman, J. (2017). A quantitative driver model of pre-crash brake onset and control. Proceedings of the Human Factors and Ergonomics Society Annual Meeting, 61, 339–343. [https://doi.org/10.1177/1541931213601565](https://doi.org/10.1177/1541931213601565)

and as a more task-general model of sustained intermittent control in:

> Markkula, G., Boer, E., Romano, R., & Merat, N. (2018). Sustained sensorimotor control as intermittent decisions about prediction errors: Computational framework and application to ground vehicle steering. Biological Cybernetics, 112(3), 181–207. [https://doi.org/10.1007/s00422-017-0743-9](https://doi.org/10.1007/s00422-017-0743-9)

The code for this latter paper, including an implementation of the task-general model, is available at: [https://doi.org/10.17605/OSF.IO/DF9PW](https://doi.org/10.17605/OSF.IO/DF9PW)


## Other information

This work was part of the Vinnova FFI [QUADRA](https://www.vinnova.se/en/p/quantitative-driver-behaviour-modelling-for-active-safety-assessment-quadra/) project, and the project partners have approved the public sharing of this repository. If you share it onwards, please include all the files in it, including this README and the LICENSE.txt.

There is also a persistent DOI link for this repository: [https://doi.org/10.17605/OSF.IO/KHDT7](https://doi.org/10.17605/OSF.IO/KHDT7)




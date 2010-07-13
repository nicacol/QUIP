! H0 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
! H0 X
! H0 X   libAtoms+QUIP: atomistic simulation library
! H0 X
! H0 X   Portions of this code were written by
! H0 X     Albert Bartok-Partay, Silvia Cereda, Gabor Csanyi, James Kermode,
! H0 X     Ivan Solt, Wojciech Szlachta, Csilla Varnai, Steven Winfield.
! H0 X
! H0 X   Copyright 2006-2010.
! H0 X
! H0 X   These portions of the source code are released under the GNU General
! H0 X   Public License, version 2, http://www.gnu.org/copyleft/gpl.html
! H0 X
! H0 X   If you would like to license the source code under different terms,
! H0 X   please contact Gabor Csanyi, gabor@csanyi.net
! H0 X
! H0 X   Portions of this code were written by Noam Bernstein as part of
! H0 X   his employment for the U.S. Government, and are not subject
! H0 X   to copyright in the USA.
! H0 X
! H0 X
! H0 X   When using this software, please cite the following reference:
! H0 X
! H0 X   http://www.libatoms.org
! H0 X
! H0 X  Additional contributions by
! H0 X    Alessio Comisso, Chiara Gattinoni, and Gianpietro Moras
! H0 X
! H0 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

#include "error.inc"

program example_LJ
use libAtoms_module
use QUIP_module
implicit none

  character(len=10240) lj_str
  type(Potential) pot
  type(Atoms) at
  type(DynamicalSystem) ds

  real(dp) :: e
  real(dp), allocatable :: f(:,:)
  integer it

  integer :: ierror = ERROR_NONE

  call system_initialise()

  lj_str = '<LJ_params n_types="1">' // &
   '<per_type_data type="1" atomic_num="29" />' // &
   '<per_pair_data type1="1" type2="1" sigma="2.0" eps6="2.0" eps12="2.0" cutoff="4.0" energy_shift="T" linear_force_shift="T" />' // &
   '</LJ_params>'

  call Initialise(pot, "IP LJ", lj_str)

  call print(pot)

  call read(at, "md.xyz", ierror=ierror)
  HANDLE_ERROR(ierror)
  call ds_initialise(ds, at)

  call set_cutoff(ds%atoms, cutoff(pot))


  allocate(f(3,ds%atoms%N))
  call rescale_velo(ds, 300.0_dp)

  call print(at)
  call print(ds%atoms)

  do it=1, 3
    if (mod(it,5) == 1) then
      call calc_connect(ds%atoms)
    end if

    call calc(pot, ds%atoms, e = e, f = f)

    call advance_verlet(ds, 1.0_dp, f)
    call ds_print_status(ds, 'D', e)
  end do

  call print(ds%atoms)

end program

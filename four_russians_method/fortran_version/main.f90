
program hello
    implicit none

    !Data section Start
    integer             :: m
    integer, parameter  :: N = 100

    integer             :: i, j

    integer*1, dimension(N, N)          :: matrix1
    integer*1, dimension(N, N)          :: matrix2
    integer*1, dimension(N, N)          :: matrix_res
    !Data section End

    read*, m
    write(*,*) m


    read(*,*) ((matrix1(i, j), j = 1, m), i = 1, m)

    call print_matrix(matrix1, m, m)

    print *, "Hello World!"


    contains

    subroutine print_matrix(matrix, matrix_vsize, matrix_hsize)
        implicit none
        ! Data section Start
        integer                         :: i, j
        integer                         :: matrix_vsize, matrix_hsize
        integer*1, dimension(:, :)        :: matrix
        ! Data section End

        do i = 1, matrix_vsize
            do j = 1, matrix_hsize
                if (j < matrix_hsize) then
                    write(*, 100) matrix(i, j)
                    100 format (I1, ' ', $)
                else
                    write(*, 101) matrix(i, j)
                    101 format (I1, ' End of row')
                end if

            end do
        end do
    end subroutine

end program


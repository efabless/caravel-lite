#!/usr/local/bin/python

import argparse
from cmath import log
import logging
import os
import subprocess
from sys import stdout
import count_lvs
import glob
import run_pt_sta


def build_caravel(caravel_root, mcw_root, pdk_root, log_dir, pdk_env):
    os.environ["CARAVEL_ROOT"] = caravel_root
    os.environ["MCW_ROOT"] = mcw_root
    os.environ["PDK_ROOT"] = pdk_root
    os.environ["PDK"] = pdk_env

    if glob.glob(f"{caravel_root}/gds/*.gz"):
        logging.error("Compressed gds files. Please uncompress first.")
        exit(1)

    gpio_defaults_cmd = ["python3", f"scripts/gen_gpio_defaults.py"]
    build_cmd = [
        "magic",
        "-noconsole",
        "-dnull",
        "-rcfile",
        f"{pdk_root}/{pdk_env}/libs.tech/magic/{pdk_env}.magicrc",
        "tech-files/build.tcl",
    ]
    log_file_path = f"{log_dir}/build_caravel.log"
    with open(log_file_path, "w") as build_log:
        subprocess.run(
            gpio_defaults_cmd, cwd=caravel_root, stderr=build_log, stdout=build_log
        )
        subprocess.run(build_cmd, stderr=build_log, stdout=build_log)


def run_drc(caravel_root, log_dir, signoff_dir, pdk_root, design):
    klayout_drc_cmd = [
        "python3",
        "klayout_drc.py",
        "-g",
        f"{caravel_root}/gds/{design}.gds",
        "-l",
        f"{log_dir}",
        "-s",
        f"{signoff_dir}",
        "-d",
        f"{design}",
    ]
    p1 = subprocess.Popen(klayout_drc_cmd)
    return p1


def run_lvs(
    caravel_root, mcw_root, log_dir, signoff_dir, pdk_root, lvs_root, pdk_env, design
):
    myenv = os.environ.copy()
    myenv["PDK_ROOT"] = pdk_root
    myenv["PDK"] = pdk_env
    myenv["LVS_ROOT"] = lvs_root
    myenv["LOG_ROOT"] = log_dir
    myenv["CARAVEL_ROOT"] = caravel_root
    myenv["MCW_ROOT"] = mcw_root
    myenv["SIGNOFF_ROOT"] = os.path.join(signoff_dir, f"{design}")
    myenv["WORK_DIR"] = os.path.join(caravel_root, "extra_be_checks")

    if not os.path.exists(f"{lvs_root}"):
        subprocess.run(
            [
                "git",
                "clone",
                "https://github.com/d-m-bailey/extra_be_checks.git",
                "-b",
                f"{design}",
            ],
            cwd=f"{caravel_root}/scripts",
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )

    lvs_cmd = [
        "bash",
        "./run_full_lvs",
        f"{design}",
        f"{caravel_root}/verilog/gl/{design}.v",
        f"{design}",
        f"{caravel_root}/gds/{design}.gds",
    ]
    p1 = subprocess.Popen(
        lvs_cmd,
        env=myenv,
        cwd=f"{caravel_root}/scripts/extra_be_checks",
        universal_newlines=True,
    )
    return p1


def run_verification(caravel_root, pdk_root, pdk_env, sim, simulator="vcs"):
    myenv = os.environ.copy()
    myenv["PDK_ROOT"] = pdk_root
    myenv["PDK"] = pdk_env
    if simulator == "vcs":
        ver_cmd = [
            "python3",
            "verify_cocotb.py",
            "-tag",
            f"CI_{sim}",
            "-r",
            f"r_{sim}",
            "-v",
        ]
    else:
        ver_cmd = [
            "python3",
            "verify_cocotb.py",
            "-tag",
            f"CI_{sim}",
            "-r",
            f"r_{sim}",
        ]
    p1 = subprocess.Popen(
        ver_cmd,
        cwd=f"{caravel_root}/verilog/dv/cocotb",
        env=myenv,
        universal_newlines=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    return p1


def run_sta(caravel_root, mcw_root, pt_lib_root, log_dir, signoff_dir, design):
    myenv = os.environ.copy()
    myenv["CARAVEL_ROOT"] = caravel_root
    myenv["MCW_ROOT"] = mcw_root
    myenv["PT_LIB_ROOT"] = pt_lib_root
    if not os.path.exists(f"{pt_lib_root}"):
        subprocess.run(
            [
                "git",
                "clone",
                "git@github.com:efabless/mpw-2-sta-debug.git",
            ],
            cwd=f"{caravel_root}/scripts",
            stdout=subprocess.PIPE,
        )
    sta_cmd = [
        "python3",
        "run_pt_sta.py",
        "-a",
        "-d",
        f"{design}",
        "-o",
        f"{signoff_dir}/{design}",
        "-l",
        f"{log_dir}",
    ]
    p1 = subprocess.Popen(
        sta_cmd,
        cwd=f"{caravel_root}/scripts",
        env=myenv,
        universal_newlines=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    return p1


def check_errors(caravel_root, log_dir, signoff_dir, drc, lvs, verification, sta, design):
    f = open(os.path.join(signoff_dir, f"{design}/signoff.rpt"), "w")
    count = 0
    if drc:
        drc_count_klayout = os.path.join(log_dir, f"{design}_klayout_drc.total")
        with open(drc_count_klayout) as rep:
            if rep.readline().strip() != "0":
                logging.error(f"klayout DRC failed")
                f.write("Klayout MR DRC:    Failed")
                count = count + 1
            else:
                logging.info("Klayout MR DRC:    Passed")
                f.write("Klayout MR DRC:    Passed")
    if lvs:
        lvs_summary_report = open(
            os.path.join(signoff_dir, f"{design}/lvs_summary.rpt")
        )
        lvs_report = os.path.join(signoff_dir, f"{design}/{design}.lvs.rpt")
        failures = count_lvs.count_LVS_failures(args.file)
        if failures[0] > 0:
            lvs_summary_report.write("LVS reports:")
            lvs_summary_report.write("    net count difference = " + str(failures[5]))
            lvs_summary_report.write(
                "    device count difference = " + str(failures[6])
            )
            lvs_summary_report.write("    unmatched nets = " + str(failures[1]))
            lvs_summary_report.write("    unmatched devices = " + str(failures[2]))
            lvs_summary_report.write("    unmatched pins = " + str(failures[3]))
            lvs_summary_report.write("    property failures = " + str(failures[4]))
            logging.error(f"LVS on {design} failed")
            logging.info(f"Find full report at {lvs_report}")
            logging.info(f"Find summary report at {lvs_summary_report}")
            f.write("Layout Vs Schematic:    Failed")
        else:
            logging.info("Layout Vs Schematic:    Passed")
            f.write("Layout Vs Schematic:    Passed")

    if verification:
        for sim in ["rtl", "gl", "sdf"]:
            verification_report = os.path.join(
                caravel_root, f"/verilog/dv/cocotb/sim/CI_{sim}/runs.log"
            )
            with open(verification_report) as rep:
                if "(0)failed" in rep.read():
                    logging.info(f"{sim} simulations:    Passed")
                    f.write(f"{sim} simulations:    Passed")
                else:
                    logging.error(
                        f"{sim} simulations failed, find report at {verification_report}"
                    )
                    f.write(f"{sim} simulations:    Failed")
                    count = count + 1

    if sta:
        sta_logs = glob.glob(f"{log_dir}/{design}/{design}-*sta.log")
        for l in sta_logs:
            with open(l) as rep:
                log_name = l.split("/")[-1]
                log_name = log_name.split(".")[0]
                lines = rep.readlines()
                if "Passed" in lines[-1]:
                    logging.info(f"{log_name} STA:    Passed")
                    f.write(f"{log_name} STA:    Passed")
                else:
                    logging.error(lines[-1])
                    logging.error(f"{log_name} STA:    Failed")
                    f.write(f"{log_name} STA:    Failed")

    if count > 0:
        return False
    return True


if __name__ == "__main__":
    logging.basicConfig(
        level=logging.DEBUG,
        format=f"%(asctime)s | %(levelname)-7s | %(message)s",
        datefmt="%d-%b-%Y %H:%M:%S",
    )
    parser = argparse.ArgumentParser(description="CI wrapper")
    parser.add_argument(
        "-drc",
        "--drc_check",
        help="run drc check",
        action="store_true",
    )
    parser.add_argument(
        "-l",
        "--lvs_check",
        help="run lvs check",
        action="store_true",
    )
    parser.add_argument(
        "-v",
        "--verification",
        help="run verification",
        action="store_true",
    )
    parser.add_argument(
        "-rtl",
        "--rtl",
        help="run rtl verification",
        action="store_true",
    )
    parser.add_argument(
        "-gl",
        "--gl",
        help="run gl verification",
        action="store_true",
    )
    parser.add_argument(
        "-sdf",
        "--sdf",
        help="run sdf verification",
        action="store_true",
    )
    parser.add_argument(
        "-iv",
        "--iverilog",
        help="run verification using iverilog",
        action="store_true",
    )
    parser.add_argument(
        "-sta",
        "--primetime_sta",
        help="run verification using iverilog",
        action="store_true",
    )
    parser.add_argument(
        "-d",
        "--design",
        help="design under test",
        required=True,
    )
    parser.add_argument(
        "-a",
        "--all",
        help="run all checks",
        action="store_true",
    )
    args = parser.parse_args()

    if not os.getenv("PDK_ROOT"):
        logging.error("Please export PDK_ROOT")
        exit(1)
    if not os.getenv("PDK"):
        logging.error("Please export PDK")
        exit(1)
    caravel_redesign_root = os.path.dirname(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    )
    if os.getenv("CARAVEL_ROOT") == None:
        caravel_root = os.path.join(caravel_redesign_root, "caravel")
        logging.warning(f"CARAVEL_ROOT is not defined, defaulting to {caravel_root}")

    if os.getenv("MCW_ROOT") == None:
        mcw_root = os.path.join(caravel_redesign_root, "caravel_mgmt_soc_litex")
        logging.warning(f"MCW_ROOT is not defined, defaulting to {mcw_root}")

    if not os.path.exists(f"{caravel_root}"):
        logging.error(f"{caravel_root} does not exist!")
        exit(1)
    if not os.path.exists(f"{mcw_root}"):
        logging.error(f"{mcw_root} does not exist!")
        exit(1)

    pdk_root = os.getenv("PDK_ROOT")
    pdk_env = os.getenv("PDK")
    log_dir = os.path.join(caravel_root, "scripts/logs")
    signoff_dir = os.path.join(caravel_root, "signoff")
    lvs_root = os.path.join(caravel_root, "scripts/extra_be_checks")
    drc = args.drc_check
    lvs = args.lvs_check
    rtl = args.rtl
    gl = args.gl
    sdf = args.sdf
    iverilog = args.iverilog
    verification = args.verification
    sta = args.primetime_sta
    design = args.design

    
    if not os.path.exists(f"{log_dir}"):
        os.makedirs(f"{log_dir}")
    if not os.path.exists(f"{signoff_dir}/{design}"):
        os.makedirs(f"{signoff_dir}/{design}")

    if design == "caravel":
        logging.info("Building caravel...")
        build_caravel(caravel_root, mcw_root, pdk_root, log_dir, pdk_env)
    else:
        logging.info(f"running checks on {design}")

    if args.all:
        drc = True
        lvs = True
        verification = True
        sta = True

    if drc:
        drc_p1 = run_drc(caravel_root, log_dir, signoff_dir, pdk_root, design)
        logging.info(f"Running klayout DRC on {design}")
    if lvs:
        lvs_p1 = run_lvs(
            caravel_root,
            mcw_root,
            log_dir,
            signoff_dir,
            pdk_root,
            lvs_root,
            pdk_env,
            design,
        )
        logging.info(f"Running LVS on {design}")

    if sta:
        logging.info(f"Running PrimeTime STA all corners on {design}")
        sta_p = run_sta(
            caravel_root,
            mcw_root,
            f"{caravel_root}/scripts/mpw-2-sta-debug/pt_libs",
            log_dir,
            signoff_dir,
            design,
        )

    if verification or iverilog:
        verify_p = []
        sim = []
        if rtl:
            sim.append("rtl")
        if gl:
            sim.append("gl")
        if sdf:
            sim.append("sdf")
        if not rtl and not gl and not sdf:
            sim = ["rtl", "gl", "sdf"]
        if verification:
            simulator = "vcs"
        elif iverilog:
            simulator = "iverilog"
        for sim_type in sim:
            logging.info(f"Running all {sim_type} verification on caravel")
            verify_p.append(
                run_verification(caravel_root, pdk_root, pdk_env, sim_type, simulator)
            )
        for i in range(len(verify_p)):
            out, err = verify_p[i].communicate()
            ver_log = open(f"{log_dir}/{sim[i]}_caravel.log", "w")
            if err:
                logging.error(err.decode())
                ver_log.write(err)
            if out:
                ver_log.write(out)

    if lvs and drc and sta:
        out, err = sta_p.communicate()
        sta_log = open(f"{log_dir}/PT_STA_{design}.log", "w")
        if err:
            logging.error(err.decode())
            sta_log.write(err)

        drc_p1.wait()
        lvs_p1.wait()
    if lvs:
        lvs_p1.wait()
    if drc:
        drc_p1.wait()
    if sta:
        out, err = sta_p.communicate()
        sta_log = open(f"{log_dir}/PT_STA_{design}.log", "w")
        if err:
            logging.error(err.decode())
            sta_log.write(err)

    if not check_errors(
        caravel_root, log_dir, signoff_dir, drc, lvs, verification, sta,  design,
    ):
        exit(1)
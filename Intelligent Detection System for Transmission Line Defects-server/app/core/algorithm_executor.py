import asyncio
import importlib
import logging
import os
import shutil
import traceback
from multiprocessing import Queue
import queue
import importlib.util
from pathlib import Path
import yaml

async def result_listener(pm):
    """安全增强型结果监听循环"""
    while getattr(pm, "running", True):
        try:
            item = await asyncio.wait_for(
                asyncio.get_event_loop().run_in_executor(
                    None,
                    lambda: pm.global_queue.get(block=True, timeout=0.5)
                ),
                timeout=1.5
            )
            async with pm.lock:
                task_id, result = item
                logging.info(f"Received result for task {task_id}")

                if task_id in pm.task_map:
                    p, temp_dir, future = pm.task_map.pop(task_id)
                    if not future.done():
                        if isinstance(result, tuple) and len(result) >= 2 and result[0] == "ERROR":
                            future.set_exception(Exception(result[1]))
                        else:
                            future.set_result(result)
                    if temp_dir and os.path.exists(temp_dir):
                        shutil.rmtree(temp_dir, ignore_errors=True)
        except (asyncio.TimeoutError, queue.Empty):
            continue
        except Exception as e:
            if pm.running:
                logging.error(f"监听错误: {str(e)}")
            else:
                break

def run_algorithm(task_id: str, temp_dir: str, args: dict, queue: Queue, algo_name: str):
    """安全封装的算法执行函数"""
    try:
        zip_path = os.path.join(temp_dir, "uploaded.zip")
        config = yaml.safe_load(Path('config.yaml').read_text(encoding='utf-8'))
        info = config['algorithms'].get(algo_name)
        if not info:
            raise ValueError(f'算法未注册：{algo_name}')
        source = Path(info['file']).resolve()
        if not source.is_relative_to(Path('algo').resolve()):
            raise ValueError('算法路径无效')
        spec = importlib.util.spec_from_file_location(f'algo.task_{task_id}', source)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        algorithm = getattr(module, "algorithm")
        result = algorithm(zip_path=zip_path, **args)
        queue.put((task_id, result))
    except Exception as e:
        queue.put((task_id, ("ERROR", str(e))))
        logging.error(f"Algorithm failed: {traceback.format_exc()}")
